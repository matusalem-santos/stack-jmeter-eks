# Stack Jmeter EKS

## Objetivo

- Provisionar Stack do Jmeter no EKS via Terraform na AWS

## Descrição

- Será provisionado o Jmeter distribuído no EKS configurado para armazenar as métricas do teste dentro do influxdb e tera um grafana para visualização dessas métricas e geração de relatório usando o grafana-reporter

## Modo de Usar

Para o provisionamento do Jmeter você tem duas opções: 

- Opção 1 - Clonar o reporitório e realizar o deploy localmente

- Opção 2 - Usar o Terraform Cloud para realizar o deploy

### Opção 1 

- Lembre-se de definir as variáveis **AWS_ACCESS_KEY_ID** e **AWS_SECRET_ACCESS_KEY** com as credenciais de um usuario do iam na conta que deseja realizar o provisionamento

- Certifique-se de que o usuário tenha as permissões necessarias para realizar a criação de toda a stack no ambiente

### Opção 2

### Passo 1 - Criar Workspace no Terraform Cloud

- Acessar o Terraform Cloud através do link: [Terraform Cloud](https://app.terraform.io/app/monit/workspaces)

#### Como criar um novo Workspace

- Clicar em **New workspace**
 <img src="http://i.imgur.com/Rpu8ne9.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Clicar em **Version control workflow**
 <img src="http://i.imgur.com/GerSRWu.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />
     
- Realize a conexão com o VCS que está armazenado o seu repositório 

- Escolha o repositório que é o fork desse reporitório

- Definir o nome do Workspace com o nome do ambiente do jmeter e clicar em **Create workspace**
### Passo 2 - Adicionar variáveis no workspace

Antes de executar o terraform é necessario definir algumas variáveis para se obter as informações necessárias para o provisionamento do Jmeter

- Clicar em **Variables**
 <img src="http://i.imgur.com/bPhF86e.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

#### Variáveis

| Nome | Descrição | Padrão | Obrigatória | 
|------|-----------|--------|:-----------:|
|AWS_SECRET_ACCESS_KEY|Secret key da conta que sera provisionado o ambiente|Vazio|Sim|
|AWS_ACCESS_KEY_ID|Access key da conta que sera provisionado o ambiente|Vazio|Sim|
|aws_region|Região onde os recursos serão provisionados|us-east-1|Não|
|env|Ambiente que sera provisionado|dev|Não|
|vpc_cidr|Cidr da VPC que será provisionada|172.35.0.0/16|Não|
|subnet_count|Quantidade de subnets a serem criadas|3|Não|
|eks_instance_type|Tipo da instancia do node group|m5.xlarge|Não|
|workspace|Nome do app que sera provisionado|jmeter-eks|Não|

#### Observações 

- Na variável **AWS_SECRET_ACCESS_KEY** assinalar **Sensitive**
 <img src="http://i.imgur.com/ZnFEU9F.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Usar credenciais de um usuário no IAM que tenha permissão de Administrador 

### Passo 3 - Executar o Projeto

- Após a configuração das variáveis, clicar em **Queue plan**
 <img src="http://i.imgur.com/n5cgf5f.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Ir em **Runs** e verificar a execução
 <img src="http://i.imgur.com/RQSQ5E6.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

## Verificar provisionamento

### Passo 1 - Se conectar com o EKS

- Certifique-se de ter o **kubectl** instalado na sua maquina

- Após a conclusão do deploy será mostrado os outputs com o valor de algumas variáveis do Terraform
- Nos outputs procure pela variavél **kubeconfig** e copie o seu valor e cole no arquivo **~./kube/config**

 <img src="http://i.imgur.com/TRv35jV.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

 <img src="http://i.imgur.com/FrnDhGI.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Teste sua conexão com o cluster

### Passo 2 - Verificar se os Pods estão rodando

- A aplicação do Jmeter esta dentro do namespace **jmeter**

- Execute o comando **kubectl get pods -n jmeter** e verifique se a saída é parecida com a imagem abaixo: 
 <img src="http://i.imgur.com/iJk79JP.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

## Acessar o Grafana

- Para acessar o Grafana execute o comando **kubectl get svc jmeter-grafana -n jmeter** e copie o endpoint do loadbalancer
 <img src="http://i.imgur.com/xNRrx2e.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Acesse o Grafana usando um browser passando o endpoint do loadbalancer na porta **3000**
 <img src="http://i.imgur.com/B28GdwR.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

## Acessar o Dashboard JMeter Metric Template

- Por padrão o Dashboard do Jmeter já vem no Grafana, para acessa-lo siga os passos abaixo:

- Clique em **Home**
 <img src="http://i.imgur.com/o2VE1Ll.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Clique no Dashboard **JMeter Metric Template**
 <img src="http://i.imgur.com/e6EWGCd.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

## Gerar Relatório do Dashboard JMeter Metric Template

- Para gerar um relatório do dashboard é usado o grafana-reporter que já vem por padrão na stack e já esta configurado dentro do dashboard **JMeter Metric Template**

- Clique em **Jmeter Reporter** dentro do dashboard **JMeter Metric Template**
 <img src="http://i.imgur.com/M119nEz.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Será aberto outra aba do seu browser com um PDF com as métricas do dashboard 
 <img src="http://i.imgur.com/tBPSsTB.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

## Executar o Teste

- Baixe os scripts para realização do teste que se encontram em [scripts](scripts)

- Para não precisar baixar todo o projeto acesse cada script e baixe cada um individualmente
 <img src="http://i.imgur.com/SET6TWa.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />
 <img src="http://i.imgur.com/IVZ4pa0.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- É necessário ter um arquivo **jmx** com o plano de teste do jmeter

- Para realizar o test execute o script **start_test.sh** passando como paramêtro o arquivo **jmx**. Exemplo:
```bash
    ./start_test.sh /path/test-jmeter.jmx
```

- Verifique se a saída é parecida com a imagem abaixo: 
 <img src="http://i.imgur.com/op3kfi2.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

- Certifique-se de que o dashboard **JMeter Metric Template** foi populado com as métricas de execução do teste
 <img src="http://i.imgur.com/cdvFbej.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 10px;" />

#### Observações

- Para testes em alta escala pode ser necessário alterar o tipo da instância para uma instância da família  **R** com uma quantidade maior de memória e se for o caso aumentar a quantidade de nodes e pods
