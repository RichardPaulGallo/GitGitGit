classdef ImportData
    properties (Access = public)
        JSON
        Cell
        String
        Double
        delim
    end
    
    methods
        function self = ImportData(JSON,delim)
            self.JSON = JSON;
            self.delim = delim;
        end
        
        function other = CellToDouble(self)
            it = 0;
            other.Cell(:) = split(self.JSON,self.delim);
            Test = zeros(length(other.Cell(:)),1);
            for k=1:length(other.Cell(:))
                Test(k) = str2double(other.Cell{k}(20:length(other.Cell{k})-4));
                if(~isnan(Test(k)))
                    it = it + 1;
                    other.Double(it) = Test(k);
                end
            end
            
        end
    end
end

