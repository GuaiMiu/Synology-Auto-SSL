### 起因

letsencrypt的SSL证书只有三个月有效期，相信大家的nas也都使用了SSL证书，来开启HTTPS。三个月的有效期每次手动申请手动上传很麻烦，因此不断百度发现使用acme.sh 配合群晖的任务计划能够自动更新证书。

可能张大妈已经有了同类型的，但我认为我的那个垃圾脚本可能要方便一点（只是可能）

开了双重验证登录的也可以使用

### 过程

1、群晖打开container manager 搜索acme下载第一个|或者使用Xshell等工具连接SSH 使用以下命令拉去镜像

```
docker pull neilpang/acme.sh
```

![Snipaste_2023-06-24_17-22-54](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/Snipaste_2023-06-24_17-22-54.png)

2、运行acme.sh镜像 docker名一定要是acme不然后面的垃圾脚本可能你要自己更改。

![Snipaste_2023-06-24_17-28-18](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/Snipaste_2023-06-24_17-28-18.png)

3、映射目录，随你怎么放。

![image-20230624172933950](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624172933950.png)

4、网络选择HOST 执行命令中填写daemon

![image-20230624173052396](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624173052396.png)

![image-20230624173137879](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624173137879.png)

5、现在开始写一个脚本并添加到群晖的任务计划中执行

![image-20230624201055809](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624201055809.png)

忽略我那奇葩的变量名，能用就行，我只测试了腾讯云，完美使用，阿里云和CF写了配置但没有测试，所以希望有小白鼠帮忙试一下。

```
#你的域名
DOMAIN=''
#证书供应商
CERT_SERVER='letsencrypt'
#DNS供应商 可选 dns_dp(腾讯云) dns_ali(阿里云)  dns_cf  其他可查https://github.com/acmesh-official/acme.sh/wiki/dnsapi
DNS="dns_dp"
#群晖账号密码
SYNO_Username=''
SYNO_Password=''
#如果开启了双重验证请在浏览器登录时选中保存此设备，然后从COOKIE中获取did cookie
SYNO_TOTP_SECRET=''
#以下群晖配置非必要不要更改
SYNO_Hostname="localhost" # Specify if not using on localhost
SYNO_Scheme="http"
SYNO_Port="5000"
#要添加的证书的名字，空字符串（""）的话就是替代默认证书，一般建议使用空字符串，除非你有多个证书
SYNO_Certificate='' 

#以下三选一
#DNSPOD.CN 腾讯云
DP_Id=''
DP_Key=''
#阿里云
Ali_Key=''
Ali_Secret=''
#CF
CF_Key=''
CF_Email=''


case $DNS in 
    "dns_dp")
    a="DP_Id=${DP_Id}"&&b="DP_Key=${DP_Key}"
    ;;
    "dns_ali")
    a="Ali_Key=${Ali_Key}"&&b="Ali_Secret=${Ali_Secret}"
    ;;
    "dns_cf")
    a="CF_Key=${CF_Key}"&&b="CF_Email=${CF_Email}"
    ;;
esac
c="SYNO_Username=${SYNO_Username}"
d="SYNO_Password=${SYNO_Password}"
e="SYNO_TOTP_SECRET=${SYNO_TOTP_SECRET}"
f="SYNO_Hostname=${SYNO_Hostname}"
g="SYNO_Scheme=${SYNO_Scheme}"
h="SYNO_Port=${SYNO_Port}"
i="SYNO_Certificate=${SYNO_Certificate}"
j="SYNO_DID=${SYNO_TOTP_SECRET}"



docker exec -e ${a} -e ${b} acme acme.sh --log --server "${CERT_SERVER}" --issue -d "${DOMAIN}" -d "*.${DOMAIN}" --dns "${DNS}" 
docker exec -e ${c} -e ${d} -e ${e} -e ${f} -e ${g} -e ${h} -e ${i} -e ${j} acme acme.sh --issue -d "${DOMAIN}" -d "*.${DOMAIN}" --dns "${DNS}" --deploy --deploy-hook synology_dsm 

```

6、现在将脚本上传到群晖并添加任务计划。

![image-20230624201718676](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624201718676.png)

![image-20230624201749833](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624201749833.png)

![image-20230624201945690](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624201945690.png)

### 双重认证

1、如果你开启了双重认证需要获取DID

![image-20230624202142132](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624202142132.png)

2、按F12打开开发者工具

<img src="https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624202412823.png" alt="image-20230624202412823" />

3、将复制的值填入

![image-20230624202450757](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/image-20230624202450757.png)

### 结果

![Snipaste_2023-06-24_20-09-11](https://guaimiu-1251795976.cos.ap-chengdu.myqcloud.com/img/Snipaste_2023-06-24_20-09-11.png)

### 总结

弄这个的原因主要是网络上的教程，不知道怎么回事我怎么弄都不行，然后就自己弄了以下，其实都大差不差。