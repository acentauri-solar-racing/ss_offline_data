# ss_offline_data route

This folder contains the general codes to obtain route data and preprocess them.

Steps:
1. First, the geo-location information of the route of interest has to be exported from Brouter:
- Browse this website: https://brouter.de/brouter-web/#map=8/47.539/9.331/standard&profile=car-fast
- Insert points start and end point of the route (also points in the middle are possible)
- Export the data:
    - Choose .geojson extension
    - Do not choose WayPoint format

2. Second, the data have to be precrocessed
- Run setup.m to ensure that all relevant functions are added to visible path
- Run route_preprocess.m
    - Select the .geojson file
    - Save the preprocess file in the folder you want
