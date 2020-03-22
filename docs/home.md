Welcome to the pymatgen-vasp- wiki!  
  
**如果公式不能正常显示,请安装插件:**
[MathJax Plugin for Github](https://chrome.google.com/webstore/detail/mathjax-plugin-for-github/ioemnmodlmafdkllaclgeombjnmnbima)
## 前言
    
&emsp;&emsp;本项目开始于2019年10月29日，主要内容是第一性原理结合高通量库对电解质及电极材料进行计算以预测其性能。开这个项目是因为初入计算方向，经历坎坷颇多，希望能记录自己的学习历程，同时将来组里可能还会有其他师弟师妹接触这个方向，也算是给他们铺路吧，希望他们在未来的科研路上能少些坎坷，节省些时间。  
  
  
# 1.第一性原理计算（DFT）
&emsp;&emsp;使用vasp进行DFT计算，计算体系的能量并结合materials project 和pymatgen计算体系的ehull(enery above the hull); 首先了解一下什么是第一性原理： 
>根据原子核和电子相互作用的原理及其基本运动规律，运用量子力学原理，从具体要求出发，经过一些近似处理后直接求解薛定谔方程的算法，习惯上称为第一性原理。   

&emsp;&emsp;简单来说，计算材料学包括很多方法，比如量子力学方法、分子动力学方法、Monte Carlo（蒙特卡洛）方法和有限元分析方法等，其中量子力学方法的核心是求描述体系状态的波函数和体系可能具有的能量，即求解薛定谔方程。实际问题中求解薛定谔方程十分困难，因此一般采用求近似解的方法，包括微扰理论、变分原理和密度泛函理论。这里我们主要了解一下密度泛函理论（DFT）  
**薛定谔方程:**  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/schrodinger.JPG" width = "400" height = "80" /></div>   
&emsp;&emsp;方括号中三项分别为每个电子的动能、每个电子与所有原子核之间的作用能、不同电子间的作用能。$\psi$是电子波函数(N维，N为电子总数)，E是电子基态能量。该方程中没有时间变量t，因此这是一个定态薛定谔方程。<br/>
<br/>  
<br/>  

_以下内容主要参考自《Density Functional Theory——A Practical Introduction》_   
## 1.1 密度泛函理论DFT(density functional theory)
  密度泛函理论的理论基础是Hohenberg-Kohn定理：
+ 定理一：从薛定谔方程得到的基态能量是电荷密度的唯一函数，或者说基态电荷密度唯一决定了基态的所有性质，包括能量和波函数
+ 定理二：使整体泛函最小化的电荷密度就是对应于薛定谔方程完全解的真实电荷密度。  

将上述定理中的泛函写成单电子波函数的形式，则能量泛函可以写成  
 <div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/energy.jpg" width = "300" height = "30"/></div>   
其中，将泛函分开为能够简单解析的“know”项和“XC”项，前者包括四部分，后者是交换关联泛函，它的定义是没有包含在“know”项中的所有其他量子力学效应。  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/Eknow.JPG" width = "450" height = "90"/></div>   
上式中的四项分别为：电子的动能，电子和原子核之间的库伦作用，电子之间的库伦作用，原子核之间的库伦作用。   

&emsp;&emsp;那么问题来了，我们如何求总能泛函的最小能量解呢，W.Kohn和L.J.Sham给出了答案：Kohn-Sham方程：  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/KS.JPG" width = "400" height = "50"/></div>   
式中三个V为三个势能项，其中第二个为Hatree势能，可以写为：
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/Hatree.JPG" width = "250" height = "50"/></div>  
  该势能描述的是一个K-S方程所考虑的单个电子，与该问题中全部电子所产生的总电荷密度之间的库伦排斥作用。其中包含了自作用，这在物理上是不存在的，因此需要在交换作用能中进行修正。$V_{XC}$可以在形式上表示为交换关联能的“泛函导数”，及  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/XC.JPG" width = "250" height = "60" /></div>  
&emsp;&emsp;但是到这里出了一点问题, 我们陷入了一个死循环:
`求单电子波函数->求解K-S方程->需要确定Hatree势能->需要知道电荷密度n(r)->需要知道单电子波函数。`  
为了解决这个问题，我们需要使用迭代算法来处理：  

```
1. 定义一个初始的、尝试性的电荷密度n(r);
2. 根据第一步的电荷密度n(r)求解K-S方程，得到单电子波函数;
3. 计算由第二步K-S方程得到的电荷密度;
4. 比较得到的电荷密度与第一步使用的电荷密度，若相同则为基态电荷密度，试用其来计算总能，若不同则进行修正重复以上过程。
```
以上便是自洽求解的过程，如果想不太懂可以了解一下牛顿迭代法，会对自洽(self-consistent)求解有更深刻的理解。  
## 1.2 交换关联泛函
&emsp;&emsp;由上一节我们知道，要得到电荷密度只需求解K-S方程即可，而求解K-S方程还有一个问题：交换关联方程$E_{XC}[\phi_i]$, 而实际上我们并不清楚交换关联泛函的真实形式。因此我们需要近似：   
+ 局域密度近似(Local Density Approximation,LDA)   
对于均匀电子气，n(r)=constant, 此时交换关联泛函可以直接导出，我们可以根据每个位置观测到的电荷密度，由均匀电子气得到交换关联能，然后将其作为该位置的交换关联势能，即   
<center>$V_{XC}(r) = V^{electron gas}_{XC}[n(r)]$</center>   

该近似仅仅使用了局域密度来确定近似的交换关联泛函，因此称作局域密度近似(LDA)，由于只是近似，我们求解K-S方程得到的结果并不能严格求解真实的薛定谔方程。
     
+ 广义梯度泛函(Generalized Gradient Approximation,GGA)   
GGA不仅考虑了局域电荷密度，还考虑了电荷密度的局域梯度（即导数），因此通常来讲更加准确，   
<center>$V^{GGA}_{XC}(r) = V_{XC}[n(r),\bigtriangledown n(r)]$</center>  

可以采用不同的方法将电荷密度的梯度包含在GGA泛函中，因此GGA有许多种，常用的有Perdew-Wang(PW91)和Perdew-Burke-Ernzerhof(PBE), 此外还有RPBE、WC等。   
     
+ 含动能密度的广义梯度近似(meta-GGA)   
由GGA定义可知，如果在泛函中包含更多信息，则可以提高其精度，我们可以进一步将密度函数的二阶梯度考虑进去，这就是meta-GGA方法，可以写作：   
<center>$V^{GGA}_{XC}(r) = V_{XC}[n(r),\bigtriangledown n(r),\bigtriangledown ^2n(r)]$</center>  
      
+ 杂化泛函（Hybrid Functionals）   
Hartree-Fock自洽场近似方法可以给出体系精确交换能，用该交换能与DFT中的交换能做线性组合得到体系的交换关联泛函称为杂化泛函，且可以通过线性组合系数调节两者比例，使结果更准确。该类型的泛函包括HSE06、B3LYP等。    
<center>$V^{B3LYP}_{XC}= V_{XC}^{LDA}+\alpha_1(E^exchange-V_X^{LDA})+\alpha_2(V_X^{GGA}-V_X^{LDA})+\alpha_3(V_C^{GGA}-V_C^{LDA})$</center>  

## 1.3 DFT计算的基本要素  
### 1. 倒易空间与k点  
#### 1) 概念  
这是固体物理里面的概念，我们知道，对于晶体来讲其在三维空间中是周期性重复排列的，可以采用三个晶格矢量$a_1$、$a_2$、$a_3$来定义一个晶胞（超胞），我们可以定义一个倒易空间（也叫k空间），在该空间中，我们用$b_1$、$b_2$、$b_3$来表示超胞，b称为倒格矢。  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/vector.JPG" width = "450" height = "50"/></div>   
我们将倒易空间的原胞称为布里渊区（Brillouin Zone,BZ）。BZ的体积记作V$_BZ$, 对应的实空间中的原胞体积记作$V_{cell}$, 则  
<center>V$_{BZ}$ = $\frac{(2\pi)^3}{V_{cell}}$</center>  
<div align=center><img src="https://github.com/JabinHao/vasp-py/blob/master/picture/space.JPG" width = "600" height = "300"/></div>  
倒空间中几个比较重要的k点进行了单独命名： 
 
|k point|name|  
:-:|:-:|  
|(0,0,0)|$\Gamma$|  
|(1,0,0)|X|  
|(3/4,3/4,0)|K|  
|(1/2,1/2,1/2)|L|  
#### 2) k点取值  
&emsp;&emsp;一般采用Monkhorst-Pack方法取点，只需给出M*M*M中的M值即可，通常k点越多计算结果越准确但消耗的时间也越长。由于对称性，计算时并不会对整个布里渊区进行积分，而是使用不可约布里渊区(IBZ)，因此，尽管采用的k点数为M*M*M，实际计算中的k点数会少于M$^3$个。在Monkhorst-Pack方法中，使用奇数M会包括IBZ边界上的一些K点，而偶数M则只包含IBZ内部的点，因此当使用少量K点时，使用偶数M收敛性更好一些。  
&emsp;&emsp;当然，实际计算中三个晶格矢量长度通常不同，由于倒空间格矢与正空间呈倒数关系，当三者不同时，M点应相应的改变比例以保证各方向K点密度相同。比如对FCC取：  
```
a,0,0  
0,a,0  
0,0,4a  
```  
则相应的K点网格应取 M * M * M/4 (比如8 * 8 * 2)。  
#### 3) 特殊情况——金属  
金属存在费米面，在K空间中的积分不连续，需要大量的K点才能给出收敛精度较高的结果，因此要采用一些近似方法，常用的有四面体方法和模糊化方法(Fermi-Dirac函数)。  
### 2. 截断能(Energy Cutoffs)  
待续  
### 3.赝势  
待续  
# 2. 计算软件——Vasp  
第一性原理计算的软件有很多，主流的是vasp跟castep，本项目中使用的是vasp5.4.4。此外还需要一些建模及可视化软件，如 Materials Studio、VESTA、p4vasp、vaspkit等。  
_这一部分主要参考大师兄科研网：[learn vasp the hard way](https://www.bigbrosci.com/)_  
  
# 3. 数据处理及后续分析  
Vasp计算结束后
