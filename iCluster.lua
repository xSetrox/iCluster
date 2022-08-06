util.require_natives("1651208000")

resources_dir = filesystem.resources_dir() .. '/icluster/'
needle = directx.create_texture(resources_dir .. 'needle.png')
speedometer_case = directx.create_texture(resources_dir .. 'speedometer_case.png')
check_engine_light = directx.create_texture(resources_dir .. 'check_engine.png')
tach_case = directx.create_texture(resources_dir .. 'tach_case.png')
high_beam = directx.create_texture(resources_dir .. 'highbeam.png')
low_beam = directx.create_texture(resources_dir .. 'lowbeam.png')
tpms = directx.create_texture(resources_dir .. 'tpms.png')
traction_control = directx.create_texture(resources_dir .. 'traction.png')

unit = 1
menu.list_select(menu.my_root(), "Units", {"iclusterunits"}, "", {"MPH", "KPH"}, 1, function(index)
    unit = index 
end)


white = {
    r = 1,
    g = 1,
    b = 1,
    a = 1.0
}

orange = {
    r = 1.0,
    g = 0.5,
    b = 0,
    a = 1
}

blue = {
    r = 0, 
    g = 0, 
    b = 1, 
    a = 1
}

green = {
    r = 0, 
    g = 1, 
    b = 0, 
    a = 1
}

local lights, high_lights = memory.alloc_int(), memory.alloc_int()
while true do 
    vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if vehicle ~= 0 and PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then 
        local vecs = ENTITY.GET_ENTITY_SPEED_VECTOR(vehicle, true)
        local v_hdl = entities.handle_to_pointer(vehicle)
        local speed = ENTITY.GET_ENTITY_SPEED(vehicle)
        local mph = speed * 2.236936
        local kph = speed * 3.6
        local max = VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(vehicle)
        local max_mph = max * 2.236936
        local max_kph = max * 3.6

        if unit == 1 then 
            measured_speed = mph 
            measured_max = max_mph
        else
            measured_speed = kph 
            measured_max = max_kph
        end
        local speed_rotation = (measured_speed/measured_max)*0.32
        local rpm = entities.get_rpm(v_hdl)
        if rpm == 1 then 
            -- rev limiter simulation
            rpm = rpm + math.random(-2, 2)*0.01
        end
        local tach_rotation = rpm*0.45
        directx.draw_texture(speedometer_case, 0.05, 0.05, 0.5, 0.5, 0.7, 0.8, 0, white)
        directx.draw_texture(needle, 0.023, 0.023, 0.88, 0.125, 0.70, 0.82, speed_rotation, white)
        -- speed text also i guess what
        directx.draw_text(0.699, 0.87, math.ceil(measured_speed), 5, 0.8, white, true)
        -- rpm gauge
        directx.draw_texture(tach_case, 0.05, 0.05, 0.5, 0.5, 0.83, 0.8, 0, white)
        -- rpm needle
        directx.draw_texture(needle, 0.023, 0.023, 0.88, 0.125, 0.83, 0.82, tach_rotation, white)
        -- rpm text
        directx.draw_text(0.829, 0.87, math.ceil(rpm*5000), 5, 0.8, white, true)
        -- gear text 
        gear = entities.get_current_gear(v_hdl)
        if gear == 0 and vecs.y < 0 then 
            gear = "R"
        end
        if VEHICLE.GET_VEHICLE_ENGINE_HEALTH(vehicle) < 1000 then
            directx.draw_texture(check_engine_light, 0.01, 0.01, 0.5, 0.5, 0.66, 0.92, 0, orange)
        end
        VEHICLE.GET_VEHICLE_LIGHTS_STATE(vehicle, lights, high_lights)
        if memory.read_byte(lights) == 1 then 
            if memory.read_byte(high_lights) == 1 then 
                directx.draw_texture(high_beam, 0.01, 0.01, 0.5, 0.5, 0.71, 0.92, 0, blue)
            else
                directx.draw_texture(low_beam, 0.01, 0.01, 0.5, 0.5, 0.69, 0.92, 0, green)
            end
        end
        any_tires_burst = false 
        for i = 1, 4 do 
            if VEHICLE.IS_VEHICLE_TYRE_BURST(vehicle, i, false) then 
                any_tires_burst = true 
            end
        end
        if any_tires_burst then 
            directx.draw_texture(tpms, 0.01, 0.01, 0.5, 0.5, 0.74, 0.92, 0, orange)
        end

        directx.draw_text(0.764, 0.87, gear, 5, 1.2, white, true)
        if VEHICLE.IS_VEHICLE_IN_BURNOUT(vehicle) or vecs.x > 3 then 
            directx.draw_texture(traction_control, 0.01, 0.01, 0.5, 0.5, 0.77, 0.92, 0, orange)

        end
        
    end
    util.yield()
end
