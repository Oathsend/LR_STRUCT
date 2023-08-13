#= Generates parameters defined by the environmental conditions section of LR_NS. =#

include(srcdir("wavedata.jl"))

function get_service_area_wavedata(serviceAreaString)
    #= Returns the service area data for a given service area. =#
    #= variables:
        serviceAreaString = Service Area Notation (eg. SA1, SA2.)
        H_s = wave height for service area [m]
        T_z = mean wave period [s]
        T_sd = standard deviation of wave period [s]
        H_x = extreme design wave height [m]
    =#
    saDict = Dict(
        "SA1" => Dict("H_s" => 5.5, "T_z" => 8.0, "T_sd" => 1.7, "H_x" => 18.5),
        "SA2" => Dict("H_s" => 4.0, "T_z" => 7.0, "T_sd" => 1.7, "H_x" => 13.5),
        "SA3" => Dict("H_s" => 3.6, "T_z" => 6.8, "T_sd" => 1.7, "H_x" => 9.5),
        "SA4" => Dict("H_s" => 2.5, "T_z" => 6.0, "T_sd" => 1.5, "H_x" => 6.0),
    )
    return saDict[serviceAreaString]
	end

function get_normal_wave_design_criteria(serviceAreaString)
    #= Returns the wave design criteria for a given service area. =#
    #= variables:
        H_dw = design wave height [m]
        T_dw = design wave period [s]
        T_dsd = design wave period standard deviation [s]
        T_drange = design wave period range [s]
    =#
    serviceAreaData = get_service_area_wavedata(serviceAreaString)
    H_dw = 1.67 * serviceAreaData["H_s"]
    T_dw = serviceAreaData["T_z"]
    T_dsd = serviceAreaData["T_sd"]
    T_drange = (T_dw - 2 * T_dsd, T_dw + 2 * T_dsd)
    return H_dw, T_dw, T_dsd, T_drange
	end

function get_extreme_wave_design_criteria(serviceAreaString)
    #= Returns the extreme wave design criteria for a given service area. =#
    #= variables:
        H_xw = extreme wave height [m]
        T_xw = extreme wave period [s]
        T_xrange = extreme wave period range [s]
        stormDuration = storm duration [s]
    =#

    serviceAreaData = get_service_area_wavedata(serviceAreaString)
    normalwd = get_normal_wave_design_criteria(serviceAreaString)

    H_xw = serviceAreaData["H_x"]
    T_xw = normalwd[2] + normalwd[3]
    T_xrange = (T_xw - 1.5 * normalwd[3], T_xw + 1.5 * normalwd[3])
    stormDuration = 10800

    return H_xw, T_xw, T_xrange, stormDuration
	end

function get_residual_strength_design_criteria(serviceAreaString)
    #= Returns the residual strength design criteria for a given service area. =#
    #= variables:
        H_rw = residual wave height [m]
        T_rw = residual wave period [s]
        T_rrange = residual wave period range [s]
        seaStateDuration = sea state duration [s]
    =#
    serviceAreaData = get_service_area_wavedata(serviceAreaString)
    normalwd = get_normal_wave_design_criteria(serviceAreaString)

    H_rw = 0.9 * serviceAreaData["H_s"]
    T_rw = normalwd[2]
    T_rrange = normalwd[4]
    seaStateDuration = 43200

    return H_rw, T_rw, T_rrange, seaStateDuration
	end

function get_service_area_factors(serviceAreaString, waterlineLength, operationalLife=20)
    #= Returns the service area factors for a given service area. =#
    #= variables:
    =#

    factorDict = Dict(
    "SA1" => Dict("F_1" => 1.0, "F_2" => 0.0),
    "SA2" => Dict("F_1" => 0.93, "F_2" => -1.15),
    "SA3" => Dict("F_1" => 0.7, "F_2" => -1.0),
    "SA4" => Dict("F_1" => 0.5, "F_2" => 0.0),
    )

    lifeFactor = Dict(
    20 => 1.0,
    25 => 1.01,
    30 => 1.019
    )

    areaFactor = (factorDict[serviceAreaString]["F_1"] + factorDict[serviceAreaString]["F_2"] * (waterlineLength - 100) / 1000) * lifeFactor[operationalLife]

    return areaFactor, lifeFactor[operationalLife]
	end

function get_restricted_service_criteria(t::Array{@NamedTuple{seaarea::Integer, P_i::Float64}}, waterlineLength::Float64, operationalLife::Integer=20)
    #= Returns the restricted service criteria for a given service area. =#
	#= variables:

	t = ((sea_area_no, P_i), ...)
	wdData[sea_area_no] = (H_si, T_zi, T_sdi, H_xi)
	wfData[sea_area_no] = (F_1i, F_2i)

    H_s = weighted average wave height plus one standard deviation [m]
    T_dw = weighted average of wave periods [s]
    =#

    lifeFactor = Dict(
    20 => 1.0,
    25 => 1.01,
    30 => 1.019
    )
    H_sm = sum(get_wdData(i[1])[1] * i[2] for i in t)
    T_dw = sum(get_wdData(i[1])[2] * i[2] for i in t)
    H_s = H_sm + sqrt(sum(i[2] * (get_wdData(i[1])[1])^2 for i in t))
    T_sd = sqrt(sum(i[2] * (get_wdData(i[1])[3]^2 + (T_dw - get_wdData(i[1])[2])^2) for i in t))
    H_xm = sum(get_wdData(i[1])[4] * i[2] for i in t)
    H_x = H_xm + sqrt(sum(i[2] * (get_wdData(i[1])[4] - H_xm)^2 for i in t))
    F_s = log(sum(i[2] * exp(1)^(get_wfData(i[1])[1] + get_wfData(i[1])[2] * (waterlineLength - 100) / 1000) for i in t))

    return H_s, T_dw, T_sd, H_x, F_s, lifeFactor[operationalLife]
	end
