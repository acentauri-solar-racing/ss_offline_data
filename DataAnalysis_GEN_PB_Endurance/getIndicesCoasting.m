function [index_coastingStart_speed, index_coastingEnd_speed, index_coastingStart_power, index_coastingEnd_power] = getIndicesCoasting(coastingEnd_dt, icu_heartbeat, bms_pack_voltage_current)
%GETDATATHUN Summary of this function goes here
%   Detailed explanation goes here
    coastingEnd_unix = posixtime(coastingEnd_dt);
    index_coastingEnd_speed = find(icu_heartbeat.timestamp > coastingEnd_unix);
    index_coastingEnd_speed = index_coastingEnd_speed(1);
    index_coastingEnd_power = find(bms_pack_voltage_current.timestamp > coastingEnd_unix);
    index_coastingEnd_power = index_coastingEnd_power(1);
    
    % find start of coasting
    foundStart = false;
    for i = index_coastingEnd_power:-1:1
        if ( - bms_pack_voltage_current.voltage(i) .* bms_pack_voltage_current.current(i) ) / 1000000 > 50
            foundStart = true;
            index_coastingStart_power = i;
            break;
        end
    end
    index_coastingStart_speed = find(icu_heartbeat.timestamp < bms_pack_voltage_current.timestamp(i));
    index_coastingStart_speed = index_coastingStart_speed(end);
end

