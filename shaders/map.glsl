vec2 getPedestal(vec3 p) {
    float ID = 9.0;
    float resDist;
    // box 1
    p.y += 13.8;
    float box1 = fBoxCheap(p, vec3(8, 0.4, 8));
    // box 2
    p.y -= 6.4;
    float box2 = fBoxCheap(p, vec3(7, 6, 7));
    // box 3
    pMirrorOctant(p.zx, vec2(7.5, 7.5));
    float box3 = fBoxCheap(p, vec3(5, 4, 1));
    // res
    resDist = box1;
    resDist = min(resDist, box2);
    resDist = fOpDifferenceColumns(resDist, box3, 1.9, 10.0);
    return vec2(resDist, ID);
}

vec2 map(vec3 p){
    //эта штука рендерит сцену
    //пол

    vec3 tpm, op = p;

    float planeDist = fPlane(p, vec3(0, 1, 0), 10.0);
    float planeID = 6.0;
    vec2 plane = vec2(planeDist, planeID);

    //оператор бесконечного повторения объекта
    //p = mod(p, 4.0) - 4.0 * 0.5;
    //pMod3(p, vec3(5)); // из hg_sdf.glsl

    // cube
   // vec3 pb = p;
    //translateCube(pb);
   // rotateCube(pb);
    //float cubeDist = fBoxCheap(pb, vec3(cubeSize));
   // float cubeID = 5.0;
   // vec2 cube = vec2(cubeDist, cubeID);

    // pedestal
    vec2 pedestal = getPedestal(p);

    //сфера
    vec3 ps = p;
    translateSphere(ps);
    rotateSphere(ps);
    float sphereDist = fSphere(ps, 6.0);
    sphereDist += bumpMapping(u_texture6, ps, ps + sphereBumpFactor,
                              sphereDist, sphereBumpFactor, sphereScale);
    sphereDist += sphereBumpFactor;
    float sphereID = 10.0;
    vec2 sphere = vec2(sphereDist, sphereID);

    //модули смещения
    //отзеркалим по 2 осям
    pMirrorOctant(p.xz, vec2(50, 50));
    //повторение вдоль оси с шагом
    pMod1(p.z, 15);
    //модуль по оси с заданным смещением
    p.x = -abs(p.x) + 21;

    
    //крыша
    vec3 pr = p;
    pr.x -=36;
    pR(pr.xy, 0.6);
    pr.y -=32.0;
    float roofDist = fBox2(pr.xy, vec2(20, 0.3));
    roofDist -= bumpMapping(u_texture7, p, p - roofBumpFactor, roofDist, roofBumpFactor, roofScale);
    roofDist += roofBumpFactor;
    float roofID = 8.0;
    vec2 roof = vec2(roofDist, roofID);

    //коробка
    float boxDist = fBox(p, vec3(3, 9, 4));
    float boxID = 3.0;
    vec2 box = vec2(boxDist, boxID);

    //цилиндр
    vec3 pc = p;
    pc.y -= 9.0;
    float cylinderDist = fCylinder(pc.yxz, 4, 3);
    float cylinderID = 3.0;
    vec2 cylinder = vec2(cylinderDist, cylinderID);

    //стена
    float wallDist = fBox2(p.xy, vec2(1, 15));
    wallDist -= bumpMapping(u_texture3, op, op + wallBumpFactor, wallDist, wallBumpFactor, wallScale);
    wallDist += wallBumpFactor;
    float wallID = 7.0;
    vec2 wall = vec2(wallDist, wallID);


    //result 
    //vec2 res = sphere;
    vec2 res;
    //res = wall;
    res = fOpUnionID(box, cylinder);
    res = fOpDifferenceColumnsID(wall, res, 0.6, 3.0);
    res = fOpUnionChamferID(res, roof, 0.9);
    res = fOpUnionStairsID(res, plane, 4.0, 5.0);
    //res = fOpUnionID(res, sphere);
    //res = fOpUnionID(res, cube);
    res = fOpUnionID(res, sphere);
    res = fOpUnionID(res, pedestal);
    return res;
    //res = fOpUnionID(res, plane);
    
}