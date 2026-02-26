Config = {}

-- Pizzeria & Luigi NPC
Config.Pizzeria = {
    coords = vector3(288.8834, -963.8314, 28.4186),
    vehicle = vector4(291.5721, -957.4305, 29.2665, 94.9705),
    luigi = {
        model = 's_m_y_busboy_01',
        coords = vector4(288.8834, -963.8314, 28.4186, 350.8256),
        name = 'Luigi Moretti',
        tag = "Pizza Stack",
        color = "#e74c3c",
        startMSG = 'Bonjour, tu veux travailler ?',
        animDict = "friends@frj@ig_1",
        animName = "wave_a",
        interactionSpeech = "GENERIC_HI"
    },
    blip = {
        sprite = 889,
        color = 17,
        scale = 0.5,
        label = "Pizzeria Luchetti's"
    }
}

-- Job Settings
Config.Job = {
    vehicleModel = `pizzaboy`,
    vehiclePlate = "PIZZA",
    maxPizzas = 8,
    payoutCoefficient = 0.1, -- Pay per distance unit
}

-- Marker Settings
Config.Marker = {
    type = 2, -- Bobbing Arrow
    size = {x = 1.0, y = 1.0, z = 1.0},
    color = {r = 255, g = 165, b = 0, a = 150}, -- Orange
    bobUpAndDown = true,
    faceCamera = true,
    rotate = true,
    drawDistance = 50.0
}

-- Server-side payouts
Config.Payouts = {
    tipChance = 30, -- 30% chance (1 to 100 > 70)
    tipRange = {min = 100, max = 200},
    endJobBonus = {min = 10, max = 100}
}

-- Delivery Points
Config.DeliveryPoints = {
    {name = "Vinewood Hills",x = -1220.50, y = 666.95 , z = 143.10},
    {name = "Vinewood Hills",x = -1338.97, y = 606.31 , z = 133.37},
    {name = "Rockford Hills",x = -1051.85, y = 431.66 , z = 76.06 },
    {name = "Rockford Hills",x = -904.04 , y = 191.49 , z = 68.44 },
    {name = "Rockford Hills",x = -21.58  , y = -23.70 , z = 72.24 },
    {name = "Hawick"        ,x = -904.04 , y = 191.49 , z = 68.44 },
    {name = "Alta"          ,x = 225.39  , y = -283.63, z = 28.25 },
    {name = "Pillbox Hills" ,x = 5.62    , y = -707.72, z = 44.97 },
    {name = "Mission Row"   ,x = 284.50  , y = -938.50 , z = 28.35},
    {name = "Rancho"        ,x = 411.59  , y = -1487.54, z = 29.14},
    {name = "Davis"         ,x = 85.19   , y = -1958.18, z = 20.12},
    {name ="Chamberlain Hills",x = -213.00, y =-1617.35 , z =37.35},
    {name ="La puerta"      ,x = -1015.65, y =-1515.05 ,z = 5.51},
    {name ="chez un client" ,x= -1004.788, y=-1154.824,z = 1.64603},
    {name ="chez un client" ,x= -1113.937, y=-1193.136,z = 1.827304},
    {name ="chez un client" ,x= -1075.903, y=-1026.452,z = 4.031562},
    {name ="chez un client" ,x= -1056.485, y=-1001.234,z = 1.639098},
    {name ="chez un client" ,x= -1090.886, y=-926.188,z = 2.630009},
    {name ="chez un client" ,x= -1075.903, y=-1026.452,z = 4.031562},
    {name ="chez un client" ,x= -1181.652, y=-988.6455,z = 1.634243},
    {name ="chez un client" ,x= -1151.11, y=-990.905,z = 1.638789},
    {name ="chez un client" ,x= -1022.788, y=-896.3149,z = 4.908271},
    {name ="chez un client" ,x= -1060.738, y=-826.829,z = 18.69866},
    {name ="chez un client" ,x= -968.6487, y=-1329.453,z = 5.144861},
    {name ="chez un client" ,x= -1185.5, y=-1386.238,z = 4.112149},
    {name ="chez un client" ,x= -1132.848, y=-1456.029,z = 4.372081},
    {name ="chez un client" ,x= -1125.602, y=-1544.203,z = 5.391256},
    {name ="chez un client" ,x= -1084.74, y=-1558.709,z = 4.10145},
    {name ="chez un client" ,x= -1098.367, y=-1679.272,z = 3.853804},
    {name ="chez un client" ,x= -1155.863, y=-1574.202,z = 8.344403},
    {name ="chez un client" ,x= -1122.675, y=-1557.524,z = 5.277201},
    {name ="chez un client" ,x= -1108.679, y=-1527.393,z = 6.265457},
    {name ="chez un client" ,x= -1273.549, y=-1382.664,z = 3.81341},
    {name ="chez un client" ,x= -1342.454, y=-1234.849,z = 5.420023},
    {name ="chez un client" ,x= -1351.21, y=-1128.669,z = 3.626104},
    {name ="chez un client" ,x= -1343.232, y=-1043.639,z = 7.303696},
    {name ="chez un client" ,x= -729.2556, y=-880.1547,z = 22.22747},
    {name ="chez un client" ,x= -831.3006, y=-864.8558,z = 20.22383},
    {name ="chez un client" ,x= -810.4093, y=-978.4364,z = 13.74061},
    {name ="chez un client" ,x= -683.8874, y=-876.8568,z = 24.02004},
    {name ="chez un client" ,x= -1031.316, y=-903.0217,z = 3.692086},
    {name ="chez un client" ,x= -1262.703, y=-1123.342,z = 7.092357},
    {name ="chez un client" ,x= -1225.079, y=-1208.524,z = 7.619214},
    {name ="chez un client" ,x= -1207.095, y=-1263.851,z = 6.378308},
    {name ="chez un client" ,x= -1086.787, y=-1278.122,z = 5.09411},
    {name ="chez un client" ,x= -886.1298, y=-1232.698,z = 5.006698},
    {name ="chez un client" ,x= -753.5927, y=-1512.016,z = 4.370816},
    {name ="chez un client" ,x= -696.3545, y=-1386.89,z = 4.846177}
}

-- Outfit
Config.Outfit = {

    --  MALE
    Male = {
        ["tshirt_1"] = 15,  -- Sous-haut
        ["tshirt_2"] = 0,

        ["torso_1"] = 537, -- Haut principal
        ["torso_2"] = 0,

        ["arms_1"] = 5,  -- Bras
        ["arms_2"] = 0,

        ["decals_1"] = 206, -- Logo
        ["decals_2"] = 0,

        ["pants_1"] = 7, -- Pantalon
        ["pants_2"] = 0,

        ["shoes_1"] = 26, -- Chaussures
        ["shoes_2"] = 0,

        ["helmet_1"] = -1, -- Casque
        ["helmet_2"] = -1,

        ["hat_1"] = -1,    -- Chapeau alternatif
        ["hat_2"] = -1
    },


    --  FEMALE
    Female = {
        ["tshirt_1"] = 15,  -- Sous-haut
        ["tshirt_2"] = 0,

        ["torso_1"] = 581, -- Haut principal
        ["torso_2"] = 0,

        ["arms_1"] = 4,  -- Bras
        ["arms_2"] = 0,

        ["decals_1"] = 222, -- Logo
        ["decals_2"] = 0,

        ["pants_1"] = 34, -- Pantalon
        ["pants_2"] = 0,

        ["shoes_1"] = 33, -- Chaussures
        ["shoes_2"] = 2,

        ["helmet_1"] = -1, -- Casque
        ["helmet_2"] = -1,

        ["hat_1"] = -1,    -- Chapeau alternatif
        ["hat_2"] = -1
    }
}
