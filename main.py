def get_service_area_wave_data(serviceAreaString):
    '''
    Returns the service area data for a given service area.
    
    variables:
    serviceAreaString = Service Area Notation (eg. SA1, SA2.)
    H_s = wave height for service area [m]
    T_z = mean wave period [s]
    T_sd = standard deviation of wave period [s]
    H_x = extreme design wave height [m]
    
    '''	
    saDict = {
        "SA1": {"H_s": 5.5, "T_z": 8.0, "T_sd": 1.7, "H_x": 18.5},
        "SA2": {"H_s": 4.0, "T_z": 7.0, "T_sd": 1.7, "H_x": 13.5},
        "SA3": {"H_s": 3.6, "T_z": 6.8, "T_sd": 1.7, "H_x": 9.5},
        "SA4": {"H_s": 2.5, "T_z": 6.0, "T_sd": 1.5, "H_x": 6.0},
    }

    return saDict[serviceAreaString]

def get_normal_wave_design_criteria(serviceAreaString):
    '''
    Returns the wave design criteria for a given service area.
    
    variables:
    H_dw = design wave height [m]
    T_dw = design wave period [s]
    T_dsd = design wave period standard deviation [s]
    T_drange = design wave period range [s]
    
    '''
    serviceAreaData = get_service_area_wave_data(serviceAreaString)
    H_dw = 1.67 * serviceAreaData["H_s"]
    T_dw = serviceAreaData["T_z"]
    T_dsd = serviceAreaData["T_sd"]
    T_drange = (T_dw - 2 * T_dsd, T_dw + 2 * T_dsd)
    
    return H_dw, T_dw, T_dsd, T_drange

def get_extreme_wave_design_criteria(serviceAreaString):
    '''	
    Returns the extreme wave design criteria for a given service area.
    
    variables:
    H_xw = extreme wave height [m]
    T_xw = extreme wave period [s]
    T_xrange = extreme wave period range [s]
    stormDuration = storm duration [s]
    
    '''
    serviceAreaData = get_service_area_wave_data(serviceAreaString)
    normalwd = get_normal_wave_design_criteria(serviceAreaString)
    
    H_xw = serviceAreaData["H_x"]
    T_xw = normalwd[1] + normalwd[2]
    T_xrange = (T_xw - 1.5 * normalwd[2], T_xw + 1.5 * normalwd[2])
    stormDuration = 10800
    
    return H_xw, T_xw, T_xrange, stormDuration

def get_residual_strength_design_criteria(serviceAreaString):
    '''	
    Returns the residual strength design criteria for a given service area.
    
    variables:
    H_rw = residual wave height [m]
    T_rw = residual wave period [s]
    T_rrange = residual wave period range [s]
    seaStateDuration = sea state duration [s]
    
    '''
    
    serviceareaData = get_service_area_wave_data(serviceAreaString)
    normalwd = get_normal_wave_design_criteria(serviceAreaString)
    
    H_rw = 0.9 * serviceareaData["H_s"]
    T_rw = normalwd[1]
    T_rrange = normalwd[3]
    seaStateDuration = 43200
    
    return H_rw, T_rw, T_rrange, seaStateDuration

def get_service_area_factors(serviceAreaString, waterlineLength, operationalLife):
    '''
    Returns the service area factors for a given service area.
    '''	
    
    factorDict = {
        "SA1": {"F_1": 1.0, "F_2": 0.0},
        "SA2": {"F_1": 0.93, "F_2": -1.15},
        "SA3": {"F_1": 0.7, "F_2": -1.0},
        "SA4": {"F_1": 0.5, "F_2": 0.0},
    }
    
    lifeFactor = {
        "20": 1.0,
        "25": 1.01,
        "30": 1.019
    }
    
    areaFactor = (factorDict[serviceAreaString]["F_1"] + factorDict[serviceAreaString]["F_2"] * (waterlineLength - 100) / 1000) * lifeFactor[operationalLife]
    
    return areaFactor, lifeFactor[operationalLife]

def get_restricted_service_criteria(t: tuple[(int, float), ...], waterlineLength, operationalLife):
    '''
    Returns design criteria for restricted service notation.
    
    variables:
    H_s = weighted average wave height plus one standard deviation [m]
    T_dw = weighted average of wave periods [s]
    '''
    import wavedata as wd
    import math
    
    lifeFactor = {
                "20": 1.0,
                "25": 1.01,
                "30": 1.019
                }
    H_sm = sum(wd.wdData[i[0]-1][0] * i[1] for i in t)
    T_dw = sum(wd.wdData[i[0]-1][1] * i[1] for i in t)
    H_s = H_sm + math.sqrt(sum(i[1] * (wd.wdData[i[0]-1][0])**2 for i in t))
    T_sd = math.sqrt(sum(i[1] * (wd.wdData[i[0]-1][2]**2 + (T_dw - wd.wdData[i[0]-1][1])**2)) for i in t)
    H_xm = sum(wd.wdData[i[0]-1][3] * i[1] for i in t)
    H_x = H_xm + math.sqrt(sum(i[1] * (wd.wdData[i[0]-1][3] - H_xm)**2 for i in t))
    F_s = math.log(sum(i[1] * math.e**(wd.wfData[i[0]-1][0] + wd.wfData[i[0]-1][1] * (waterlineLength - 100) / 1000) for i in t))
    
    return H_s, T_dw, T_sd, H_x, F_s, lifeFactor[operationalLife]
            
    
