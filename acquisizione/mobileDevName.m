function [devName] = mobileDevName()
dev = mobiledevlist;
[row, ~] = size(dev);
for i = 1:row
    if dev.Status(i) == "Connected"
        devName = dev.Device(i);
    end
end
devName = devName{1};
end

