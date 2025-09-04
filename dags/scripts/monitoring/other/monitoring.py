if __name__ == "__main__":

    import streamlit as st
    import pandas as pd
    import datetime
    import numpy as np
    import json
    import altair as alt

    f = open("../../results/623/db/db_output_matlab_6.json")
    results = json.load(f)
    f.close()

    # f = open("feed5.json")
    # feed = json.load(f)
    # f.close()

    mbrs = list(results.keys())
    
    try:
        states = [state for state in results[mbrs[0]]["measurements_aggregated"].keys() if state != "unit"]
    except:
        states = ["Glucose", "OD600", "Acetate", "DOT"]

    params = ["qs", "qa_p_max", "qa_c_max", "Ks", "Kap", "Kac", "Ksi", "Kai", "Yas", "Yxsox", "Yxsof", "Yos", "Yoa", "Yxa", "qm", "cx", "cs", "ca"]


    st.set_page_config(layout='wide', initial_sidebar_state='expanded')

    with open('style.css') as f:
        st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)
        
    st.sidebar.header('KIWI-Experiment Monitoring')

    st.sidebar.subheader('Minibioreactors (MBRs)')
    selected_mbrs = st.sidebar.multiselect('Select MBRs', mbrs, [mbrs[0]])

    st.sidebar.subheader('States')
    selected_states = st.sidebar.multiselect('Select states', states, ["Glucose"])
    plot_height = st.sidebar.slider('Specify plot height', 200, 500, 350)

    st.sidebar.subheader('Model parameters')
    selected_params = st.sidebar.selectbox('Select parameter', params)

    st.sidebar.markdown('''---
    Open [Airflow Platform](http://localhost:8082).''')

    # Row 1
    with st.container():
        st.markdown('### Metrics')
        col1, col2, col3 = st.columns(3)
        col1.metric("Start Time", datetime.datetime.now().strftime("%H:%M:%S"))
        col2.metric("MBRs", len(mbrs))
        col3.metric("Strain", "ABC123")

    # Row 2
    if len(selected_mbrs) and len(selected_states):
        for state in selected_states:
            st.markdown(f'### {state}')

            # Concat differents MBRs states. Add ts as column and mbr label.
            pd_mbrs_states = []
            for mbr in selected_mbrs:
                pd_mbr = pd.DataFrame(results[mbr]["measurements_aggregated"][state])
                pd_mbr["mbr"] = mbr
                pd_mbrs_states.append(pd_mbr)
            
            pd_state = pd.concat(pd_mbrs_states, ignore_index=True)
            # delete None values
            print(pd_state)
            pd_state_wout_na = pd_state.dropna(axis=0, subset=state)

            # plot series from MBR selector and State selector. Order x-axes 
            chart = alt.Chart(pd_state).mark_line(point=True).encode(
                x=alt.X('measurement_time'),
                y=state,
                color="mbr:N"
            ).interactive()           

            st.altair_chart(chart, use_container_width=True)


    # Row 3
    # st.markdown(f'### Parameter distribution "{selected_params}"')
    # st.line_chart(seattle_weather, x = 'date', y = ["precipitation", "wind"], height = plot_height)
