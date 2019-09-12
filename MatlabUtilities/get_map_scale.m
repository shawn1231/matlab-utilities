function data_aspect = get_map_scale(coordinates)

scale_lng = haversine(coordinates,[coordinates(1),coordinates(2)+1],'ft');
scale_lat = haversine(coordinates,[coordinates(1)+1,coordinates(2)],'ft');

data_aspect = [1/scale_lng,1/scale_lat,1];
data_aspect = data_aspect./max(data_aspect);

end


