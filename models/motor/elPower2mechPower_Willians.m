function P_mech = elPower2mechPower_Willians(P_elec, par)
%ELPOWER2MECHPOWER_WILLIANS converts electrical motor power to mechanical motor power
%using the Willans Model
%
%   P_elec is the electric motor power, 
%   par is a struct that needs to contain e_mot and P_0, the two parameters
%   for the Willans Model.
%   The mechanical Power P_mech is returned.

    if P_elec >= 0
        P_mech = P_elec * par.e_mot - par.P_0;
    else
        P_mech = P_elec / par.e_mot - par.P_0;
    end
end

