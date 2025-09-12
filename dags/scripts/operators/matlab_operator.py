from __future__ import annotations

from airflow.providers.docker.operators.docker import DockerOperator
from airflow.exceptions import AirflowException, AirflowSkipException
from docker.types import LogConfig

def stringify(line: str | bytes):
    """Make sure string is returned even if bytes are passed. Docker stream can return bytes."""
    decode_method = getattr(line, "decode", None)
    if decode_method:
        return decode_method(encoding="utf-8", errors="surrogateescape")
    else:
        return line
    
class MatlabOperator(DockerOperator):
    
    def __init__(self, mac_address: str | None = None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.mac_address = mac_address
        self.skip_exit_code = None
        

    def _run_image_with_mounts(self, target_mounts, add_tmp_variable: bool) -> list[str] | str | None:
        if add_tmp_variable:
            self.environment["AIRFLOW_TMP_DIR"] = self.tmp_dir
        else:
            self.environment.pop("AIRFLOW_TMP_DIR", None)
        docker_log_config = {}
        if self.log_opts_max_size is not None:
            docker_log_config["max-size"] = self.log_opts_max_size
        if self.log_opts_max_file is not None:
            docker_log_config["max-file"] = self.log_opts_max_file
        env_file_vars = {}
        if self.env_file is not None:
            env_file_vars = self.unpack_environment_variables(self.env_file)
        self.container = self.cli.create_container(
            command=self.format_command(self.command),
            name=self.container_name,
            environment={**env_file_vars, **self.environment, **self._private_environment},
            host_config=self.cli.create_host_config(
                auto_remove=False,
                mounts=target_mounts,
                network_mode=self.network_mode,
                shm_size=self.shm_size,
                dns=self.dns,
                dns_search=self.dns_search,
                cpu_shares=int(round(self.cpus * 1024)),
                mem_limit=self.mem_limit,
                cap_add=self.cap_add,
                extra_hosts=self.extra_hosts,
                privileged=self.privileged,
                device_requests=self.device_requests,
                log_config=LogConfig(config=docker_log_config),
                ipc_mode=self.ipc_mode                
            ),
            image=self.image,
            user=self.user,
            entrypoint=self.format_command(self.entrypoint),
            working_dir=self.working_dir,
            tty=self.tty,
            mac_address=self.mac_address
        )
        logstream = self.cli.attach(container=self.container["Id"], stdout=True, stderr=True, stream=True)
        try:
            self.cli.start(self.container["Id"])

            log_lines = []
            for log_chunk in logstream:
                log_chunk = stringify(log_chunk).strip()
                log_lines.append(log_chunk)
                self.log.info("%s", log_chunk)

            result = self.cli.wait(self.container["Id"])
            if result["StatusCode"] == self.skip_exit_code:
                raise AirflowSkipException(
                    f"Docker container returned exit code {self.skip_exit_code}. Skipping."
                )
            elif result["StatusCode"] != 0:
                joined_log_lines = "\n".join(log_lines)
                raise AirflowException(f"Docker container failed: {repr(result)} lines {joined_log_lines}")

            if self.retrieve_output:
                return self._attempt_to_retrieve_result()
            elif self.do_xcom_push:
                if len(log_lines) == 0:
                    return None
                try:
                    if self.xcom_all:
                        return log_lines
                    else:
                        return log_lines[-1]
                except StopIteration:
                    # handle the case when there is not a single line to iterate on
                    return None
            return None
        finally:
            if self.auto_remove == "success":
                self.cli.remove_container(self.container["Id"])
            elif self.auto_remove == "force":
                self.cli.remove_container(self.container["Id"], force=True)

    