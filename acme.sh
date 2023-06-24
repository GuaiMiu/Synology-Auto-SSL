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
