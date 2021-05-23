// These are all the square water zones in SA-MP in this format: MinX, MinY, MaxX, MaxY, Height
new Float:water_squares[][] = {
	{-1584.0, -1826.0, -1360.0, -1642.0, 0.00000},
	{-3000.0, 354.0, -2832.0, 2942.0, 0.00000},
	{-2832.0, 1296.0, -2704.0, 2192.0, 0.00000},
	{-2704.0, 1360.0, -2240.0, 2224.0, 0.00000},
	{-2240.0, 1432.0, -2000.0, 2224.0, 0.00000},
	{-2064.0, 1312.0, -2000.0, 1432.0, 0.00000},
	{-2000.0, 1392.0, -1712.0, 1792.0, 0.00000},
	{-2000.0, 1792.0, -1724.0, 2016.0, 0.00000},
	{-2000.0, 2016.0, -1836.0, 2176.0, 0.00000},
	{-2000.0, 2176.0, -1920.0, 2224.0, 0.00000},
	{-2208.0, 2224.0, -2000.0, 2432.0, 0.00000},
	{-2208.0, 2432.0, -2000.0, 2576.0, 0.00000},
	{-2352.0, 2448.0, -2208.0, 2576.0, 0.00000},
	{-2312.0, 2344.0, -2208.0, 2448.0, 0.00000},
	{-1712.0, 1360.0, -1600.0, 1792.0, 0.00000},
	{-1664.0, 1280.0, -1600.0, 1360.0, 0.00000},
	{-1600.0, 1280.0, -1440.0, 1696.0, 0.00000},
	{-1600.0, 1696.0, -1488.0, 1744.0, 0.00000},
	{-1440.0, 1440.0, -1232.0, 1696.0, 0.00000},
	{-1232.0, 1440.0, -1136.0, 1616.0, 0.00000},
	{-1440.0, 1280.0, -1136.0, 1440.0, 0.00000},
	{-1136.0, 1248.0, -1104.0, 1424.0, 0.00000},
	{-1520.0, 1104.0, -1104.0, 1248.0, 0.00000},
	{-1520.0, 1248.0, -1136.0, 1280.0, 0.00000},
	{-1600.0, 1200.0, -1520.0, 1280.0, 0.00000},
	{-1104.0, 944.0, -932.0, 1136.0, 0.00000},
	{-1424.0, 944.0, -1104.0, 1104.0, 0.00000},
	{-1520.0, 1008.0, -1424.0, 1104.0, 0.00000},
	{-1424.0, 784.0, -896.0, 944.0, 0.00000},
	{-1488.0, 560.0, -896.0, 784.0, 0.00000},
	{-1536.0, 560.0, -1488.0, 672.0, 0.00000},
	{-896.0, 208.0, -768.0, 732.0, 0.00000},
	{-1600.0, 208.0, -896.0, 560.0, 0.00000},
	{-992.0, -144.0, -912.0, 208.0, 0.00000},
	{-1748.0, -816.0, -1180.0, -592.0, 0.00000},
	{-1458.0, -592.0, -1054.0, -432.0, 0.00000},
	{-3000.0, -1186.0, -2880.0, -822.0, 0.00000},
	{-2880.0, -1168.0, -2768.0, -896.0, 0.00000},
	{-2768.0, -1106.0, -2656.0, -830.0, 0.00000},
	{-2656.0, -1024.0, -2512.0, -816.0, 0.00000},
	{-2512.0, -976.0, -2400.0, -816.0, 0.00000},
	{-2400.0, -1056.0, -2256.0, -864.0, 0.00000},
	{-2256.0, -1198.0, -2144.0, -950.0, 0.00000},
	{-2144.0, -1408.0, -2000.0, -1072.0, 0.00000},
	{-2000.0, -1536.0, -1856.0, -1280.0, 0.00000},
	{-1856.0, -1648.0, -1728.0, -1440.0, 0.00000},
	{-1728.0, -1728.0, -1584.0, -1520.0, 0.00000},
	{-1360.0, -2052.0, -1216.0, -1696.0, 0.00000},
	{-1440.0, -2110.0, -1360.0, -1950.0, 0.00000},
	{-1484.0, -2180.0, -1440.0, -2036.0, 0.00000},
	{-1572.0, -2352.0, -1484.0, -2096.0, 0.00000},
	{-1216.0, -2208.0, -1104.0, -1864.0, 0.00000},
	{-1232.0, -2304.0, -1120.0, -2208.0, 0.00000},
	{-1270.0, -2480.0, -1178.0, -2304.0, 0.00000},
	{-1260.0, -2560.0, -1188.0, -2480.0, 0.00000},
	{-1262.0, -2640.0, -1146.0, -2560.0, 0.00000},
	{-1216.0, -2752.0, -1080.0, -2640.0, 0.00000},
	{-1200.0, -2896.0, -928.0, -2752.0, 0.00000},
	{-2016.0, -3000.0, -1520.0, -2704.0, 0.00000},
	{-1520.0, -3000.0, -1376.0, -2894.0, 0.00000},
	{-2256.0, -3000.0, -2016.0, -2772.0, 0.00000},
	{-2448.0, -3000.0, -2256.0, -2704.0, 0.00000},
	{-3000.0, -3000.0, -2448.0, -2704.0, 0.00000},
	{-3000.0, -2704.0, -2516.0, -2576.0, 0.00000},
	{-3000.0, -2576.0, -2600.0, -2448.0, 0.00000},
	{-3000.0, -2448.0, -2628.0, -2144.0, 0.00000},
	{-3000.0, -2144.0, -2670.0, -2032.0, 0.00000},
	{-3000.0, -2032.0, -2802.0, -1904.0, 0.00000},
	{-3000.0, -1904.0, -2920.0, -1376.0, 0.00000},
	{-3000.0, -1376.0, -2936.0, -1186.0, 0.00000},
	{-768.0, 208.0, -720.0, 672.0, 0.00000},
	{-720.0, 256.0, -656.0, 672.0, 0.00000},
	{-656.0, 276.0, -496.0, 576.0, 0.00000},
	{-496.0, 298.0, -384.0, 566.0, 0.00000},
	{-384.0, 254.0, -224.0, 530.0, 0.00000},
	{-224.0, 212.0, -64.0, 528.0, 0.00000},
	{-64.0, 140.0, 64.0, 544.0, 0.00000},
	{64.0, 140.0, 304.0, 544.0, 0.00000},
	{120.0, 544.0, 304.0, 648.0, 0.00000},
	{304.0, 164.0, 384.0, 608.0, 0.00000},
	{384.0, 222.0, 464.0, 630.0, 0.00000},
	{464.0, 304.0, 544.0, 656.0, 0.00000},
	{544.0, 362.0, 800.0, 646.0, 0.00000},
	{800.0, 432.0, 944.0, 704.0, 0.00000},
	{944.0, 480.0, 976.0, 720.0, 0.00000},
	{976.0, 528.0, 1040.0, 704.0, 0.00000},
	{1040.0, 560.0, 1280.0, 672.0, 0.00000},
	{1280.0, 480.0, 1472.0, 640.0, 0.00000},
	{1472.0, 432.0, 1616.0, 640.0, 0.00000},
	{1616.0, 416.0, 1824.0, 608.0, 0.00000},
	{1824.0, 400.0, 2160.0, 576.0, 0.00000},
	{2160.0, 400.0, 2432.0, 512.0, 0.00000},
	{2432.0, 368.0, 2560.0, 544.0, 0.00000},
	{2560.0, 336.0, 2720.0, 576.0, 0.00000},
	{2720.0, 196.0, 2816.0, 560.0, 0.00000},
	{2816.0, 160.0, 3000.0, 576.0, 0.00000},
	{2860.0, -80.0, 3000.0, 160.0, 0.00000},
	{-1376.0, -3000.0, -544.0, -2896.0, 0.00000},
	{-928.0, -2896.0, -544.0, -2800.0, 0.00000},
	{-544.0, -3000.0, -320.0, -2824.0, 0.00000},
	{-320.0, -3000.0, -192.0, -2876.0, 0.00000},
	{-192.0, -3000.0, 160.0, -2920.0, 0.00000},
	{-128.0, -2920.0, 160.0, -2872.0, 0.00000},
	{-60.0, -2872.0, 160.0, -2816.0, 0.00000},
	{-4.0, -2816.0, 160.0, -2672.0, 0.00000},
	{40.0, -2672.0, 160.0, -2256.0, 0.00000},
	{16.0, -2560.0, 40.0, -2256.0, 0.00000},
	{-32.0, -2440.0, 16.0, -2256.0, 0.00000},
	{-32.0, -2488.0, 16.0, -2440.0, 0.00000},
	{-96.0, -2440.0, -32.0, -2256.0, 0.00000},
	{-168.0, -2384.0, -96.0, -2256.0, 0.00000},
	{-224.0, -2256.0, 160.0, -2080.0, 0.00000},
	{-248.0, -2080.0, 160.0, -1968.0, 0.00000},
	{-280.0, -1968.0, -128.0, -1824.0, 0.00000},
	{-264.0, -2016.0, -248.0, -1968.0, 0.00000},
	{-264.0, -1824.0, -128.0, -1640.0, 0.00000},
	{-128.0, -1768.0, 124.0, -1648.0, 0.00000},
	{-128.0, -1792.0, 140.0, -1768.0, 0.00000},
	{-128.0, -1968.0, 148.0, -1792.0, 0.00000},
	{160.0, -2128.0, 592.0, -1976.0, 0.00000},
	{480.0, -1976.0, 592.0, -1896.0, 0.00000},
	{352.0, -1976.0, 480.0, -1896.0, 0.00000},
	{232.0, -1976.0, 352.0, -1880.0, 0.00000},
	{160.0, -1976.0, 232.0, -1872.0, 0.00000},
	{160.0, -2784.0, 592.0, -2128.0, 0.00000},
	{160.0, -3000.0, 592.0, -2784.0, 0.00000},
	{352.0, -1896.0, 544.0, -1864.0, 0.00000},
	{592.0, -2112.0, 976.0, -1896.0, 0.00000},
	{736.0, -1896.0, 904.0, -1864.0, 0.00000},
	{704.0, -1896.0, 736.0, -1728.0, 0.00000},
	{736.0, -1864.0, 752.0, -1728.0, 0.00000},
	{688.0, -1728.0, 752.0, -1480.0, 0.00000},
	{592.0, -2192.0, 976.0, -2112.0, 0.00000},
	{592.0, -2328.0, 1008.0, -2192.0, 0.00000},
	{592.0, -3000.0, 1008.0, -2328.0, 0.00000},
	{1008.0, -3000.0, 1072.0, -2368.0, 0.00000},
	{1008.0, -2368.0, 1064.0, -2320.0, 0.00000},
	{1072.0, -2672.0, 1288.0, -2412.0, 0.00000},
	{1072.0, -2768.0, 1288.0, -2672.0, 0.00000},
	{1072.0, -3000.0, 1288.0, -2768.0, 0.00000},
	{1288.0, -3000.0, 1448.0, -2760.0, 0.00000},
	{1288.0, -2760.0, 1392.0, -2688.0, 0.00000},
	{1448.0, -3000.0, 1720.0, -2754.0, 0.00000},
	{1720.0, -3000.0, 2064.0, -2740.0, 0.00000},
	{2064.0, -3000.0, 2144.0, -2742.0, 0.00000},
	{2144.0, -3000.0, 2208.0, -2700.0, 0.00000},
	{2208.0, -3000.0, 2272.0, -2684.0, 0.00000},
	{2272.0, -3000.0, 2376.0, -2312.0, 0.00000},
	{2376.0, -2480.0, 2472.0, -2240.0, 0.00000},
	{2472.0, -2376.0, 2776.0, -2240.0, 0.00000},
	{2776.0, -2336.0, 2856.0, -2192.0, 0.00000},
	{2808.0, -2560.0, 3000.0, -2336.0, 0.00000},
	{2856.0, -2336.0, 3000.0, -2136.0, 0.00000},
	{2888.0, -2136.0, 3000.0, -1840.0, 0.00000},
	{2872.0, -1880.0, 2888.0, -1840.0, 0.00000},
	{2864.0, -1840.0, 3000.0, -1720.0, 0.00000},
	{2888.0, -1720.0, 3000.0, -1664.0, 0.00000},
	{2896.0, -1664.0, 3000.0, -1592.0, 0.00000},
	{2920.0, -1592.0, 3000.0, -1504.0, 0.00000},
	{2940.0, -1504.0, 3000.0, -1344.0, 0.00000},
	{2908.0, -1344.0, 3000.0, -1096.0, 0.00000},
	{2912.0, -1096.0, 3000.0, -800.0, 0.00000},
	{2918.0, -800.0, 3000.0, -472.0, 0.00000},
	{2872.0, -472.0, 3000.0, -376.0, 0.00000},
	{2912.0, -376.0, 3000.0, -80.0, 0.00000},
	{2864.0, -376.0, 2912.0, -80.0, 0.00000},
	{2560.0, -2560.0, 2680.0, -2456.0, 0.00000},
	{-992.0, -422.0, -848.0, -238.0, 0.00000},
	{-848.0, -384.0, -512.0, -256.0, 0.00000},
	{-512.0, -400.0, -320.0, -272.0, 0.00000},
	{-320.0, -400.0, -208.0, -304.0, 0.00000},
	{-384.0, -528.0, -100.0, -460.0, 0.00000},
	{-384.0, -704.0, -64.0, -528.0, 0.00000},
	{-336.0, -816.0, -80.0, -704.0, 0.00000},
	{-208.0, -936.0, -48.0, -816.0, 0.00000},
	{-48.0, -936.0, 144.0, -874.0, 0.00000},
	{32.0, -1024.0, 128.0, -936.0, 0.00000},
	{-16.0, -1104.0, 96.0, -1024.0, 0.00000},
	{0.0, -1200.0, 144.0, -1104.0, 0.00000},
	{-16.0, -1296.0, 128.0, -1200.0, 0.00000},
	{-16.0, -1440.0, 112.0, -1296.0, 0.00000},
	{0.0, -1552.0, 96.0, -1440.0, 0.00000},
	{-128.0, -1648.0, 96.0, -1552.0, 0.00000},
	{-64.0, -672.0, 32.0, -576.0, 0.00000},
	{-64.0, -576.0, 96.0, -496.0, 0.00000},
	{16.0, -496.0, 144.0, -392.0, 0.00000},
	{144.0, -448.0, 240.0, -384.0, 0.00000},
	{240.0, -432.0, 304.0, -320.0, 0.00000},
	{304.0, -384.0, 352.0, -288.0, 0.00000},
	{352.0, -332.0, 400.0, -252.0, 0.00000},
	{400.0, -298.0, 464.0, -234.0, 0.00000},
	{464.0, -288.0, 576.0, -208.0, 0.00000},
	{576.0, -272.0, 688.0, -192.0, 0.00000},
	{688.0, -256.0, 768.0, -144.0, 0.00000},
	{768.0, -212.0, 800.0, -124.0, 0.00000},
	{800.0, -180.0, 976.0, -92.0, 0.00000},
	{976.0, -160.0, 1200.0, -64.0, 0.00000},
	{1200.0, -244.0, 1264.0, -108.0, 0.00000},
	{1264.0, -330.0, 1344.0, -158.0, 0.00000},
	{1344.0, -320.0, 1456.0, -208.0, 0.00000},
	{1456.0, -282.0, 1520.0, -198.0, 0.00000},
	{1520.0, -208.0, 1648.0, -80.0, 0.00000},
	{1568.0, -80.0, 1648.0, 16.0, 0.00000},
	{1648.0, -64.0, 1792.0, 16.0, 0.00000},
	{1792.0, -128.0, 1888.0, 0.0, 0.00000},
	{1888.0, -268.0, 2016.0, -20.0, 0.00000},
	{2016.0, -256.0, 2144.0, -16.0, 0.00000},
	{2144.0, -272.0, 2224.0, -96.0, 0.00000},
	{2224.0, -272.0, 2288.0, -144.0, 0.00000},
	{2048.0, -16.0, 2144.0, 112.0, 0.00000},
	{2096.0, 112.0, 2224.0, 240.0, 0.00000},
	{2098.0, 240.0, 2242.0, 400.0, 0.00000},
	{2160.0, 512.0, 2432.0, 576.0, 0.00000},
	{2432.0, 544.0, 2560.0, 592.0, 0.00000},
	{2560.0, 576.0, 2720.0, 608.0, 0.00000},
	{2720.0, 560.0, 2816.0, 608.0, 0.00000},
	{2816.0, 576.0, 3000.0, 752.0, 0.00000},
	{-656.0, 576.0, -496.0, 672.0, 0.00000},
	{-740.0, 672.0, -484.0, 784.0, 0.00000},
	{-720.0, 784.0, -384.0, 1008.0, 0.00000},
	{-640.0, 1008.0, -400.0, 1216.0, 0.00000},
	{-880.0, 1296.0, -688.0, 1408.0, 0.00000},
	{-688.0, 1216.0, -400.0, 1424.0, 0.00000},
	{-672.0, 1424.0, -448.0, 1616.0, 0.00000},
	{-832.0, 1616.0, -512.0, 1728.0, 0.00000},
	{-984.0, 1632.0, -832.0, 1712.0, 0.00000},
	{-832.0, 1728.0, -576.0, 2032.0, 0.00000},
	{-1248.0, 2536.0, -1088.0, 2824.0, 40.60000},
	{-1088.0, 2544.0, -1040.0, 2800.0, 40.59998},
	{-1040.0, 2544.0, -832.0, 2760.0, 40.59998},
	{-1088.0, 2416.0, -832.0, 2544.0, 40.60000},
	{-1040.0, 2304.0, -864.0, 2416.0, 40.60000},
	{-1024.0, 2144.0, -864.0, 2304.0, 40.60000},
	{-1072.0, 2152.0, -1024.0, 2264.0, 40.59999},
	{-1200.0, 2114.0, -1072.0, 2242.0, 40.60000},
	{-976.0, 2016.0, -848.0, 2144.0, 40.60000},
	{-864.0, 2144.0, -448.0, 2272.0, 40.59995},
	{-700.0, 2272.0, -484.0, 2320.0, 40.59999},
	{-608.0, 2320.0, -528.0, 2352.0, 40.59999},
	{-848.0, 2044.0, -816.0, 2144.0, 40.59998},
	{-816.0, 2060.0, -496.0, 2144.0, 40.59999},
	{-604.0, 2036.0, -484.0, 2060.0, 40.60000},
	{2376.0, -3000.0, 3000.0, -2688.0, 0.00000},
	{2520.0, -2688.0, 3000.0, -2560.0, 0.00000},
	{-1328.0, 2082.0, -1200.0, 2210.0, 40.59999},
	{-1400.0, 2074.0, -1328.0, 2150.0, 40.60000},
	{-1248.0, -144.0, -992.0, 208.0, 0.00000},
	{-1176.0, -432.0, -992.0, -144.0, 0.00000},
	{-1792.0, -592.0, -1728.0, -144.0, 0.00000},
	{-1792.0, 170.0, -1600.0, 274.0, 0.00000},
	{-1600.0, 168.0, -1256.0, 208.0, 0.00000},
	{-1574.0, -44.0, -1550.0, 108.0, 0.00000},
	{1928.0, -1222.0, 2012.0, -1178.0, 18.00000},
	{-464.0, -1908.0, -280.0, -1832.0, 0.00000},
	{2248.0, -1182.0, 2260.0, -1170.0, 23.33740},
	{2292.0, -1432.0, 2328.0, -1400.0, 22.16500},
	{1888.0, 1468.0, 2036.0, 1700.0, 8.59839},
	{2090.0, 1670.0, 2146.0, 1694.0, 9.61171},
	{2110.0, 1234.0, 2178.0, 1330.0, 7.83275},
	{2108.0, 1084.0, 2180.0, 1172.0, 7.56284},
	{2506.0, 1546.0, 2554.0, 1586.0, 8.96708},
	{1270.0, -812.0, 1290.0, -800.0, 86.67300},
	{1084.0, -684.0, 1104.0, -660.0, 112.00000},
	{502.0, -1114.0, 522.0, -1098.0, 78.42310},
	{214.0, -1208.0, 246.0, -1180.0, 74.00000},
	{218.0, -1180.0, 238.0, -1172.0, 74.00000},
	{178.0, -1244.0, 206.0, -1216.0, 77.05340},
	{1744.0, 2780.0, 1792.0, 2868.0, 8.47297},
	{-2832.0, 2888.0, 3000.0, 3000.0, 0.00000},
	{-2778.0, -522.0, -2662.0, -414.0, 2.79256},
	{1520.0, -252.0, 1572.0, -208.0, 0.00000},
	{2922.0, 752.0, 3000.0, 2888.0, 0.00000},
	{-3000.0, -446.0, -2910.0, 354.0, 0.00000},
	{-2434.0, 2224.0, -2294.0, 2340.0, 0.00000},
	{-2294.0, 2224.0, -2208.0, 2312.0, 0.00000},
	{2058.0, 1868.0, 2110.0, 1964.0, 9.62916},
	{-3000.0, 2942.0, -2832.0, 3000.0, 0.00000},
	{-550.0, 2004.0, -494.0, 2036.0, 40.60000},
	{-896.0, 842.0, -776.0, 954.0, 0.00000},
	{-2240.0, 1336.0, -2088.0, 1432.0, 0.00000},
	{-3000.0, -822.0, -2930.0, -446.0, 0.00000},
	{-2660.0, 2224.0, -2520.0, 2264.0, 0.00000},
	{-378.0, -460.0, -138.0, -400.0, 0.00000},
	{1836.0, 1468.0, 1888.0, 1568.0, 8.59839},
	{890.0, -1106.0, 902.0, -1098.0, 22.41000},
	{1202.0, -2414.0, 1278.0, -2334.0, 8.86445},
	{1072.0, -2412.0, 1128.0, -2372.0, 0.00000},
	{-848.0, -2082.0, -664.0, -1866.0, 5.27000},
	{-664.0, -1924.0, -464.0, -1864.0, 5.27000},
	{-1484.0, 784.0, -1424.0, 840.0, 0.00000},
	{-496.0, 566.0, -432.0, 642.0, 0.00000},
	{250.0, 2808.0, 818.0, 2888.0, 0.00000},
	{2502.0, -2240.0, 2670.0, -2120.0, 0.00000},
	//{1270.0, -780.0, 1290.0, -768.0, 1082.72998}, //IMPORTANT MESSAGE: THIS IS MADD DOGG'S HOUSE IN INTERIOR ID 5!
	{88.0, 544.0, 120.0, 572.0, 0.00000},
	{1856.0, -202.0, 1888.0, -158.0, 0.00000},
	{-2048.0, -962.0, -2004.0, -758.0, 30.40000},
	{2564.0, 2370.0, 2604.0, 2398.0, 16.40000},
	{-2522.0, -310.0, -2382.0, -234.0, 35.38200},
	{2872.0, -2136.0, 2888.0, -2120.0, 0.00000},
	{2760.0, -2240.0, 2776.0, -2232.0, 0.00000}
};
// These are all the triangle water zones in SA-MP. Takes some more figuring out which value is which.
// See it as ({x1,y1}, {x2,y2}, {x3,y3}, height)
// x1 is minimum X value, x5 is maximum X value
// Points 1 and two lie on the same horizontal line, that is, y1 = y2
// Point 3 is the 'pointy' end facing either upwards (north, due to higher Y) or downwards (sotuh,  due to lower Y)
// Final value is Z height value.
new Float:water_triangles[][] = {
	{-912.0, 208.0, -724.0, 208.0, -912.0, 20.0, 0.00000},
	{-1610.0, 168.0, -1550.0, 168.0, -1550.0, 108.0, 0.00000},
	{-1728.0, -62.0, -1568.0, -62.0, -1728.0, -222.0, 0.00000},
	{-1724.0, 170.0, -1612.0, 170.0, -1724.0, 58.0, 0.00000},
	{-1550.0, 168.0, -1362.0, 168.0, -1550.0, -20.0, 0.00000},
	{-1722.0, -62.0, -1574.0, -62.0, -1574.0, 86.0, 0.00000}
};

stock IsPosInWater(Float:x, Float:y, Float:z)
{
	// todo: weather based z threshold
	if(z < 1.7 && !IsPointInMapBounds(x, y, z))
		return 1;

	for(new i = 0; i < sizeof water_squares; i++) // Check the squares. This is simple.
	{
		if(z <= water_squares[i][4])
		{
			if( (water_squares[i][0] <= x <= water_squares[i][2]) && (water_squares[i][1] <= y <= water_squares[i][3]) )
				return 1;
		}
	}

	for(new i = 0; i < sizeof water_triangles; i++) // Check the triangle zones too.
	{
		if(z <= water_triangles[i][6])
		{
			// Is within X boundaries
			if(water_triangles[i][0] > x || water_triangles[i][2] < x)
				continue;

			// Is within Y boundaries check.
			if(water_triangles[i][1] > water_triangles[i][5])
			{
				if(water_triangles[i][5] > y || water_triangles[i][1] < y)
					continue;
			}
			else if(water_triangles[i][1] > y || water_triangles[i][5] < y)
			{
				continue;
			}

			// We need to apply some entry level black magic (http://totologic.blogspot.nl/2014/01/accurate-point-in-triangle-test.html)
			new Float:denominator = ( (water_triangles[i][3]-water_triangles[i][5]) * (water_triangles[i][0]-water_triangles[i][4]) ) + \
				((water_triangles[i][4] - water_triangles[i][2]) * (water_triangles[i][1] - water_triangles[i][5]));
			new Float:a = (((water_triangles[i][3] - water_triangles[i][5]) * (x - water_triangles[i][4])) + \
				((water_triangles[i][4] - water_triangles[i][2]) * (y - water_triangles[i][5]))) / denominator;
			new Float:b = (((water_triangles[i][5] - water_triangles[i][1]) * (x - water_triangles[i][4])) + \
				((water_triangles[i][0] - water_triangles[i][4]) * (y - water_triangles[i][5]))) / denominator;
			new Float:c = 1 - (a + b);

			if( (0 <= a <= 1) && (0 <= b <= 1) && (0 <= c <= 1) )
				return 1;
		}
	}
	return 0;
}


stock IsPointInMapBounds(Float:x, Float:y, Float:z)
{
	if(-3000.0 <= x <= 3000.0)
	{
		if(-3000.0 <= y <= 3000.0)
		{
			if(-100.0 <= z <= 1000.0)
			{
				return 1;
			}
		}
	}

	return 0;
}

stock returnOrdinal(number)
{
	new
		ordinal[4][3] = { "st", "nd", "rd", "th" };
	number = number < 0 ? -number : number;
	return (((10 < (number % 100) < 14)) ? ordinal[3] : (0 < (number % 10) < 4) ? ordinal[((number % 10) - 1)] : ordinal[3]);
}

stock IsNumeric(string[])
{
	for(new i,j=strlen(string);i<j;i++)if (string[i] > '9' || string[i] < '0') return 0;
	return 1;
}
stock IsCharNumeric(c)
{
	if(c>='0'&&c<='9')return 1;
	return 0;
}
stock IsCharAlphabetic(c)
{
	if((c>='a'&&c<='z')||(c>='A'&&c<='Z'))return 1;
	return 0;
}

stock strtolower(string[])
{
	new
		retStr[128],
		i,
		j;

	while ((j = string[i])) retStr[i++] = tolower(j);
	retStr[i] = '\0';

	return retStr;
}
stock UnderscoreToSpace(name[])
{
	new pos = strfind(name, "_", true);

	if(pos != -1)
	{
		name[pos] = ' ';
		return 1;
	}

	return 0;
}

stock db_escape(text[])
{
	new
		ret[256],
		ch,
		i,
		j;

	while ((ch = text[i++]) && j < sizeof (ret))
	{
		if (ch == '\'')
		{
			if (j < sizeof (ret) - 2)
			{
				ret[j++] = '\'';
				ret[j++] = '\'';
			}
		}
		else if (j < sizeof (ret))
		{
			ret[j++] = ch;
		}
		else
		{
			j++;
		}
	}
	ret[sizeof (ret) - 1] = '\0';
	return ret;
}

stock RGBAToHex(r, g, b, a)
{
	return (r<<24 | g<<16 | b<<8 | a);
}

stock HexToRGBA(colour, &r, &g, &b, &a)
{
	r = (colour >> 24) & 0xFF;
	g = (colour >> 16) & 0xFF;
	b = (colour >> 8) & 0xFF;
	a = colour & 0xFF;
}

stock truncateforbyte(cell)
{
	return ((cell < 0) ? (0) : ((cell > 255) ? (255) : cell));
}

stock IpIntToStr(ip)
{
	new str[17];
	format(str, 17, "%d.%d.%d.%d", ((ip>>24) & 0xFF), ((ip>>16) & 0xFF), ((ip>>8) & 0xFF), (ip & 0xFF) );
	return str;
}


//==============================================================================Player Functions


stock SetAllWeaponSkills(playerid, skill)
{
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE,		skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN,			skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE,		skill);
}


//==============================================================================Location / Geometrical


forward Float:GetPlayerDist3D(player1, player2);
stock Float:GetPlayerDist3D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;

	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);

	return floatsqroot( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2));
}
forward Float:GetPlayerDist2D(player1, player2);
stock Float:GetPlayerDist2D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;

	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);

	return floatsqroot( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}


//==============================================================================Skin Functions


static const SkinArray[] =
{
	3, 4, 5, 6, 7, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273,
	0,1,2,7,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37,
	38,40,43,44,45,46,47,48,49,50,51,52,57,58,59,60,61,62,66,67,68,70,71,72,73,78,
	79,80,81,82,83,84,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,110,112,
	113,114,115,116,117,118,120,121,122,123,124,125,126,127,128,131,132,133,134,135,
	136,137,142,143,144,146,147,153,154,155,156,158,159,160,161,162,163,164,165,166,
	167,168,170,171,173,174,175,176,177,179,180,181,182,183,184,185,186,187,188,189,
	200,202,203,204,206,209,210,212,213,217,220,221,222,223,227,228,229,230,234,235,
	236,239,240,241,242,247,248,249,250,252,253,254,255,258,259,260,261,262,264,265,
	266,267,269,270,271,272,274,275,276,277,278,279,280,281,282,283,284,285,286,287,
	288,289,290,291,292,293,294,295,296,297,299,
	9,10,11,12,13,31,39,41,42,53,54,55,56,63,64,69,75,76,77,85,87,88,89,90,91,92,93,
	109,111,129,130,131,138,139,140,141,145,148,150,151,152,157,169,172,178,190,191,
	192,193,194,195,196,197,198,199,201,205,207,211,214,215,216,218,219,224,225,226,
	231,232,233,237,238,243,244,245,246,251,256,257,263,298
};

stock GetSkinGender(skinID)
{
	for(new i; i<sizeof(SkinArray); i++)
	{
		if(SkinArray[i] == skinID)
		{
			switch(i)
			{
				case 0..14: return 0;
				case 15..221: return 1;
				case 222..299: return 2;
			}
			break;
		}
	}
	return 0;
}

stock IsValidSkin(skinid)
{
	if(skinid == 74 || skinid > 299 || skinid < 0)
		return 0;

	return 1;
}

stock TruncateChatMessage(input[], output[])
{
	if(strlen(input) > 127)
	{
		new splitpos;

		for(new i = 128; i > 0; i--)
		{
			if(input[i] == ' ' || input[i] ==  ',' || input[i] ==  '.')
			{
				splitpos = i;
				break;
			}
		}

		strcat(output, input[splitpos], 128);
		input[splitpos] = 0;

		return 1;
	}

	return 0;
}
