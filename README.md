# ACPW

使用 ACPW(基于主成分分析的并行粒子群优化与沃尔夫搜索算法的自适应协同进化算法) 求解WRF模式的CNOP-I，来识别目标观测敏感区。



## 文件结构

```
work_dir
|
|--files 
|    |--namelist.input  WRF模式参数设置文件
|    |--wrfbdy_d01      WRF模式边界条件
|    |--wrfinput_d01    WRF模式初始场
|    |--PCA.out         PCA结果
|    |--wrfinput_new    加了扰动的初始场
|    |--wrfout_start    默认起始时刻状态
|    |--wrfout_end      默认结束时刻状态
|    |--fort.1001       生成的扰动
|    |--adapValue.txt   目标函数值    
|
|--script   脚本文件
|    |--acpw.f90        ACPW模块
|    |--wrf.f90         WRF模块
|    |--main.f90        主程序
|    |--init.sh         初始化脚本
|    |--run.sh          运行add_pert.ncl和get_adap.ncl
|    |--add_pert.ncl    将扰动添加到初始场
|    |--get_adap.ncl    运行WRF，得到目标函数值    
| 
|-- WRF  WRF模式运行文件夹
     |--namelist.input  files/namelist.input 的软连接
     |--wrfbdy_d01      files/wrfbdy_d01 的软连接
     |--wrfinput_d01    files/wrfinput_new 的软连接
     |--...

```



## 使用步骤

1. 将 namelist.input，wrfbdy_d01，wrfinput_d01，PCA.out 放入 files 文件夹。
2. 打开 acpw.f90，wrf.f90，namelist.input调整参数。
3. 在命令行中输入
```cmd
ifort wrf.f90 acpw.f90 main.f90
./a.out
```

