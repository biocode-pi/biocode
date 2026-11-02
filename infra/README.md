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

O domínio raiz (`biocode.dev.br`, sem www) não aceita CNAME no registro.br e fica fora desta stack.
