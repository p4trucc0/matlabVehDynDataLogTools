function vo = ruota_coord(vi, s, b, r)

if size(vi, 1) == 3
    torot = false;
else
    torot = true;
end

lio = [cos(s)*cos(b) - sin(b)*sin(s)*sin(r), -cos(r)*sin(s), cos(s)*sin(b) + sin(s)*sin(r)*cos(b); ...
      sin(s)*cos(b) + cos(s)*sin(r)*sin(b), cos(s)*cos(r), sin(b)*sin(s) - cos(s)*sin(r)*cos(b); ...
      -sin(b)*cos(r), sin(r), cos(r)*cos(b)];
      
if torot
    vo = (lio*vi')';
else
    vo = lio*vi;
end