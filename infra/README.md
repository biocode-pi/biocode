# Infraestrutura (AWS)

S3 privado + CloudFront (OAC) com HTTPS, na região us-east-1. Stack separada da `smarthive`.
Custo esperado: centavos por mês (só tráfego e requisições).

## 1. Criar a stack (sem domínio)

```bash
aws cloudformation deploy --stack-name biocode --template-file infra/biocode.yaml --region us-east-1
```

O site fica disponível no endereço `*.cloudfront.net` mostrado no output `SiteUrl`.

## 2. Publicar o site

No PowerShell ou cmd:

```powershell
infra\deploy-site.cmd
```

No Git Bash:

```bash
bash infra/deploy-site.sh
```

Repita a cada alteração na página.

## 3. Domínio www.biocode.dev.br

1. Pedir o certificado (gratuito):
   ```bash
   aws acm request-certificate --region us-east-1 --domain-name www.biocode.dev.br --validation-method DNS
   aws acm describe-certificate --region us-east-1 --certificate-arn <ARN> \
     --query "Certificate.DomainValidationOptions[0].ResourceRecord"
   ```
2. No registro.br (modo avançado), criar o CNAME de validação informado. Na primeira ativação
   do modo avançado, a zona leva cerca de 2 h para entrar em vigor.
3. Quando o certificado estiver `ISSUED`, atualizar a stack:
   ```bash
   aws cloudformation deploy --stack-name biocode --template-file infra/biocode.yaml --region us-east-1 \
     --parameter-overrides Dominio=biocode.dev.br CertificadoArn=<ARN>
   ```
4. No registro.br, criar `www` como CNAME para o output `DistributionDomain`.

## 4. Domínio raiz (biocode.dev.br, sem www)

O registro.br não aceita CNAME no domínio raiz, então ele não aponta para o CloudFront. Como no
Smart Hive, o raiz aponta para o servidor da API do Smart Hive (EC2 `smarthive-api`), cujo Caddy
responde com redirecionamento 301 para `https://www.biocode.dev.br`, com certificado Let's Encrypt.

1. No registro.br, criar o registro `A` de `biocode.dev.br` para `184.197.188.214` (Elastic IP do
   `smarthive-api`).
2. No repositório do Smart Hive, rodar `bash infra/deploy-backend.sh`. A variável `DOMINIOS_EXTRAS`
   (padrão `biocode.dev.br`) gera o redirecionamento no Caddy.

Se o servidor do Smart Hive mudar de IP ou sair do ar, só o endereço sem www deixa de funcionar; o
site em `www.biocode.dev.br` continua no CloudFront.
