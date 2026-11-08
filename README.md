# Biocode

Landing page institucional da equipe Biocode: aplicações web e mobile para o setor agro.

Site estático em HTML e CSS puros, sem etapa de build e sem formulário (o contato é feito por `mailto:`).

## Rodar localmente

```bash
python -m http.server 8000
```

Depois abra http://localhost:8000.

## Estrutura

- `index.html`: conteúdo da página
- `styles.css`: estilos e paleta (cores tiradas da logo da Biocode)
- `assets/`: logo da Biocode, favicon e logo do Smart Hive

## Pendências

- Confirmar os perfis do GitHub de Bruno Davies e Bruno Eduardo.
- Hospedagem: ver `infra/README.md` (S3 + CloudFront, stack `biocode`).
