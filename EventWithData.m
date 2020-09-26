classdef (ConstructOnLoad) EventWithData < event.EventData
    
    properties
        Data = [];
    end
    
    methods
        function obj = EventWithData(n_Data)
            obj.Data = n_Data;
        end
    end
    
end