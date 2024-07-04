
function this = RunModel(this)
     
    for i= 1:numel(this.runs)
        this.runs(i).mat = this.mat;
        this.runs(i).contactCurve = this.contactCurve;
        this.runs(i).Sinter();
    end
end