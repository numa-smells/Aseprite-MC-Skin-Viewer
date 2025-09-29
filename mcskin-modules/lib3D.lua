dofile("vec3.lua")
dofile("tex2.lua")


local sin, cos  = math.sin, math.cos

-- 3D ENGINE

function triangle(p, t)
  local p = p or {Vec3(),Vec3(),Vec3(),Vec3()}
  local t = t or {Tex2(),Tex2(),Tex2(),Tex2()}

  return {
    t = t,
    p = p,
    c = 0
  }
end

function vec3D_IntersectPlane(plane_p, plane_n, lineStart, lineEnd)

  local plane_n = Vec3.norm(plane_n)
  local plane_d = -Vec3.dot(plane_n, plane_p)

  local ad = Vec3.dot(lineStart, plane_n);
  local bd = Vec3.dot(lineEnd, plane_n);
  local t = (-plane_d - ad) / (bd - ad);
  local lineStartToEnd = lineEnd - lineStart;
  local lineToIntersect = Vec3.mult(lineStartToEnd, t);
  return lineStart + lineToIntersect, t;

end

function clip(plane_p, plane_n, in_tri)
  local plane_n = Vec3.norm(plane_n)
  local dist = function(p)
    local n = Vec3.norm(p)
    return (plane_n.x * p.x + plane_n.y * p.y + plane_n.z * p.z - Vec3.dot(plane_n, plane_p))
  end
  
  -- Create two temporary storage arrays to classify points either side of plane
	-- If distance sign is positive, point lies on "inside" of plane
	-- Get signed distance of each point in triangle to plane
  local d0 = dist(in_tri.p[1])
  local d1 = dist(in_tri.p[2])
  local d2 = dist(in_tri.p[3])
  local d3 = dist(in_tri.p[4])

  return (d0 >= 0 and d1 >= 0 and d2 >= 0 and d3 >= 0)
end

function clamp(x,a,b)
  return math.max(math.min(x,b),a)
end

function lerp(a,b,t)
  return (b-a)*t + a
end

function lerp4(a,b,c,d,t1,t2)
  return ((d-c-b+a)*t1 - a+c)*t2 + ((b-a)*t1 + a)
end

function drawTri(gc, tri, texture) 
  
  local ax, ay, aw = tri.p[1].x, tri.p[1].y, tri.p[1].w 
  local bx, by, bw = tri.p[2].x, tri.p[2].y, tri.p[2].w  
  local cx, cy, cw = tri.p[3].x, tri.p[3].y, tri.p[3].w  
  local dx, dy, dw = tri.p[4].x, tri.p[4].y, tri.p[4].w  

  local au, av = tri.t[1].u, tri.t[1].v 
  local bu, bv = tri.t[2].u, tri.t[2].v 
  local cu, cv = tri.t[3].u, tri.t[3].v 
  local du, dv = tri.t[4].u, tri.t[4].v 

  local wd = (math.abs(math.max(au,bu,cu,du) - math.min(au,bu,cu,du)) * 64 // 1)
  local hd = (math.abs(math.max(av,bv,cv,dv) - math.min(av,bv,cv,dv)) * 64 // 1)

  for i=0, wd-1 do
    for j=0, hd-1 do
      local k = i/wd
      local l = j/hd
      local tex_w = 1 / wd
      local tex_h = 1 / hd

      local tex_u = lerp4(au,bu,cu,du,k+tex_w/2,l+tex_h/2)
      local tex_v = lerp4(av,bv,cv,dv,k+tex_w/2,l+tex_h/2)
      
      local c = Color(texture:getPixel(tex_u*64,tex_v*64)) 

      if c.alpha > 0 then
        c.value = c.value * tri.c

        local x1 = lerp4(ax,bx,cx,dx,k,l)
        local y1 = lerp4(ay,by,cy,dy,k,l)
        local w1 = lerp4(aw,bw,cw,dw,k,l)

        local x2 = lerp4(ax,bx,cx,dx,k+tex_w,l)
        local y2 = lerp4(ay,by,cy,dy,k+tex_w,l)
        local w2 = lerp4(aw,bw,cw,dw,k+tex_w,l)

        local x3 = lerp4(ax,bx,cx,dx,k,l+tex_h)
        local y3 = lerp4(ay,by,cy,dy,k,l+tex_h)
        local w3 = lerp4(aw,bw,cw,dw,k,l+tex_h)

        local x4 = lerp4(ax,bx,cx,dx,k+tex_w,l+tex_h)
        local y4 = lerp4(ay,by,cy,dy,k+tex_w,l+tex_h)
        local w4 = lerp4(aw,bw,cw,dw,k+tex_w,l+tex_h)

        x1 = (x1/w1 + 1) / 2 * gc.width
        y1 = (y1/w1 + 1) / 2 * gc.height

        x2 = (x2/w2 + 1) / 2 * gc.width
        y2 = (y2/w2 + 1) / 2 * gc.height

        x3 = (x3/w3 + 1) / 2 * gc.width
        y3 = (y3/w3 + 1) / 2 * gc.height

        x4 = (x4/w4 + 1) / 2 * gc.width
        y4 = (y4/w4 + 1) / 2 * gc.height
            
        gc.color = c
        
        gc:beginPath()
        gc:moveTo(x1, y1)
        gc:lineTo(x2, y2)
        gc:lineTo(x4, y4)
        gc:lineTo(x3, y3)
        
        gc.antialias = false
        gc:fill()
        
        if c.alpha == 255 then
          gc.antialias = true
          gc:stroke()
        end
      end
    end
  end
end

function splitQuad(buffer,tri,texture, gc)
  local ax, ay, aw, az = tri.p[1].x, tri.p[1].y, tri.p[1].w , tri.p[1].z
  local bx, by, bw, bz = tri.p[2].x, tri.p[2].y, tri.p[2].w , tri.p[2].z  
  local cx, cy, cw, cz = tri.p[3].x, tri.p[3].y, tri.p[3].w , tri.p[3].z  
  local dx, dy, dw, dz = tri.p[4].x, tri.p[4].y, tri.p[4].w , tri.p[4].z  

  local au, av = tri.t[1].u, tri.t[1].v 
  local bu, bv = tri.t[2].u, tri.t[2].v 
  local cu, cv = tri.t[3].u, tri.t[3].v 
  local du, dv = tri.t[4].u, tri.t[4].v 

  local wd = (math.abs(math.max(au,bu,cu,du) - math.min(au,bu,cu,du)) // 1)
  local hd = (math.abs(math.max(av,bv,cv,dv) - math.min(av,bv,cv,dv)) // 1)

  for i=0, wd-1 do
    for j=0, hd-1 do
      local k = i/wd
      local l = j/hd
      local tex_w = 1 / wd
      local tex_h = 1 / hd

      local tex_u = lerp4(au,bu,cu,du,k+tex_w/2,l+tex_h/2)
      local tex_v = lerp4(av,bv,cv,dv,k+tex_w/2,l+tex_h/2)
      
      local c = Color(texture:getPixel(tex_u,tex_v)) 

      if c.alpha > 0 then
        c.value = c.value * tri.c

        local x1 = lerp4(ax,bx,cx,dx,k,l)
        local y1 = lerp4(ay,by,cy,dy,k,l)
        local w1 = lerp4(aw,bw,cw,dw,k,l)
        local z1 = lerp4(az,bz,cz,dz,k,l)

        local x2 = lerp4(ax,bx,cx,dx,k+tex_w,l)
        local y2 = lerp4(ay,by,cy,dy,k+tex_w,l)
        local w2 = lerp4(aw,bw,cw,dw,k+tex_w,l)
        local z2 = lerp4(az,bz,cz,dz,k+tex_w,l)

        local x3 = lerp4(ax,bx,cx,dx,k,l+tex_h)
        local y3 = lerp4(ay,by,cy,dy,k,l+tex_h)
        local w3 = lerp4(aw,bw,cw,dw,k,l+tex_h)
        local z3 = lerp4(az,bz,cz,dz,k,l+tex_h)


        local x4 = lerp4(ax,bx,cx,dx,k+tex_w,l+tex_h)
        local y4 = lerp4(ay,by,cy,dy,k+tex_w,l+tex_h)
        local w4 = lerp4(aw,bw,cw,dw,k+tex_w,l+tex_h)
        local z4 = lerp4(az,bz,cz,dz,k+tex_w,l+tex_h)

        local z_ave = z1 + z2 + z3 + z4
      

        x1 = (x1/w1 + 1) / 2 * gc.width
        y1 = (y1/w1 + 1) / 2 * gc.height

        x2 = (x2/w2 + 1) / 2 * gc.width
        y2 = (y2/w2 + 1) / 2 * gc.height

        x3 = (x3/w3 + 1) / 2 * gc.width
        y3 = (y3/w3 + 1) / 2 * gc.height

        x4 = (x4/w4 + 1) / 2 * gc.width
        y4 = (y4/w4 + 1) / 2 * gc.height

        local newtri = triangle({Vec3(x1,y1,z1),Vec3(x2,y2,z2),Vec3(x3,y3,z3),Vec3(x4,y4,z4)})
        newtri.sortby = z_ave
        newtri.c = c
        table.insert(buffer, newtri)
      end
    end
  end
end

function drawQuad(gc, tri) 
  
  local ax, ay = tri.p[1].x, tri.p[1].y
  local bx, by = tri.p[2].x, tri.p[2].y
  local cx, cy = tri.p[3].x, tri.p[3].y
  local dx, dy = tri.p[4].x, tri.p[4].y

  gc.color = tri.c
        
  gc:beginPath()
  gc:moveTo(ax, ay)
  gc:lineTo(bx, by)
  gc:lineTo(dx, dy)
  gc:lineTo(cx, cy)
  gc:closePath()
  
  if tri.c.alpha == 255 then
    gc.antialias = true
    gc:fill()
    gc:stroke()
  else
    gc.antialias = false
    gc:fill()
  end
end