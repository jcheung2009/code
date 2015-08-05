function proj = vctr_proj(v1,v2);
 
 
proj = dot(v1,v2)/sqrt(sum(v2.^2));