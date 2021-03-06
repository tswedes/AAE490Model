function [PCM, m_PCM, m_PCM_struc, V_PCM, percent_V_change] = PCMSizing(E_waste, Tmin, Tmax)
    %{
    Input: Power dissipated [W] time span, efficiency factor, max and min
           operational temperatures
    Output: Mass of PCM and associated structure
    
    This function calculates the required mass of phase change material and
    associate structure based by calculating the total energy to absorb
    from heat dissipation rate, and efficiency factor, if applicable.
    
    Required temperature bounds are hard coded 
    %}
    
    % Constants
        n = 2; %index of PCM material for analysis
        T_mars = 0; %ambient temperature on Mars [C]
    
    % Motor Specifications    
    T_mars = T_mars + 273.15; %convert to K
    Tmax = Tmax + 273.15; %convert to K
    Tmin = Tmin + 273.15; %convert to K
    
    % Cell array structure: {material, T_melt, H_delta_fus, c_p_liquid, c_p_solid
    %                            rho_solid, rho_liquid, k}
    
    % Material Properties
    materialOptions = {'Water'                ,   0, 300000, 4187, 2108, 916 , 995 , 2   ;
                       '0400-Q20 BioPCM (Wax)',  20, 215000, 3200, 3500, 1075, 1125, 0.45;
                       '0100-Q50 BioPCM (Wax)', -50, 215000, 3200, 3500, 1075, 1075, 0.45;
                       '0500-Q50 BioPCM (Wax)',  50, 215000, 3200, 3500, 1075, 1075, 0.45;
                       'Inorganic'            ,  21, 200000, 3140, 3140, 1540, 1540, 1.09};
    
    PCM = materialOptions{n, 1}; %phase change material
    T_melt = materialOptions{n, 2}; %melting point [C]
    H_delta_fus = materialOptions{n, 3}; %latent heat of fusion [J/kg]
    c_p_liquid = materialOptions{n, 4}; %heat capacity of liquid [J/kg*K]
    c_p_solid = materialOptions{n, 5}; %heat capacity of solid [J/kg*K]
    rho_solid = materialOptions{n, 6}; %density of solid [kg/m^3]
    rho_liquid = materialOptions{n, 7}; %density of liquid at maximum temp [kg/m^3]
    
    T_melt = T_melt + 273.15; %melting point [K]
    T_0 = max(T_mars, Tmin);
    T_f = Tmax;
    
    % Energy absorbtion from heating solid
    if T_melt > T_0
        Q_solid_1kg = c_p_solid * (T_melt - T_0);
    else
        Q_solid_1kg = 0;
    end
    
    % Energy absorbtion from melting
    if T_melt <= T_f
        Q_melt_1kg = H_delta_fus;
    else
        Q_melt_1kg = 0;
    end
    
    % Energy abosrtion from heating liquid
    if T_melt < T_f
        Q_liquid_1kg = c_p_liquid * (T_f - T_melt);
    else
        Q_liquid_1kg = 0;
    end
    
    % Total energy absorbably in change from T_0 to T_f
    c_p_total = Q_solid_1kg + Q_melt_1kg + Q_liquid_1kg; %total heat capacity [J/kg]
    
    % Mass of system
    m_PCM = E_waste / c_p_total; %mass of PCM required to absorb heat [kg]
    m_PCM_struc = m_PCM * 0.25; %estimate of additional structurla mass required [kg]
    
    V_liquid = m_PCM / rho_liquid; %volume of liquid [m^3]
    V_solid = m_PCM / rho_solid; %volume of solid [m^3]
    V_PCM = max(V_liquid, V_solid);
    
    percent_V_change = (V_liquid - V_solid) / V_solid;
    
end