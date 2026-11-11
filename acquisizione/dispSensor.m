function [sensorMessage] = dispSensor(m)

% Abilito i sensori e riccardo sta ubriaco
m.AccelerationSensorEnabled = true;
m.AngularVelocitySensorEnabled = true;
m.OrientationSensorEnabled = true;
m.MagneticSensorEnabled = true;

% Controllo quali sensori si accendono
i = 1;

if m.AccelerationSensorEnabled == true
    mess(i)='1';
    i=i+1;
end
if m.AngularVelocitySensorEnabled == true
    mess(i)='2';
    i=i+1;
end
if m.MagneticSensorEnabled == true
    mess(i)='3';
    i=i+1;
end
if m.OrientationSensorEnabled == true
    mess(i)='4';
    i=i+1;
end
if i==5
    mess='5';
end

% Spengo i sensori
m.AccelerationSensorEnabled = false;
m.AngularVelocitySensorEnabled = false;
m.OrientationSensorEnabled = false;
m.MagneticSensorEnabled = false;

sensorMessage = mess;

end
