from pathlib import Path
import json,shutil
root=Path('ADD.NET/Лабораторные работы')
for i,folder in [(6,'ПР_06_Асинхронность'),(7,'ПР_07_Конфигурация'),(8,'ПР_08_DataTable_DataSet')]:
    path=root/folder
    project='''<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.Data.SqlClient" Version="6.1.1" />
    <PackageReference Include="System.Security.Cryptography.Pkcs" Version="10.0.13" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="10.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="10.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration.FileExtensions" Version="10.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration.EnvironmentVariables" Version="10.0.0" />
    <Compile Include="../Shared/PracticeSupport.cs" Link="PracticeSupport.cs" />
    <None Update="appsettings*.json" CopyToOutputDirectory="PreserveNewest" />
  </ItemGroup>
</Project>
'''
    (path/f'AdoNetPractice{i:02}.csproj').write_text(project,encoding='utf-8')
    config={'ConnectionStrings':{'CoffeeShop':r'Server=(localdb)\CodexSqlPractice;Database=coffee_shop;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=5'},'Application':{'Title':'Управление кофейней','ShowPrices':True}}
    (path/'appsettings.json').write_text(json.dumps(config,ensure_ascii=False,indent=2),encoding='utf-8')
    pdf=next(p for p in Path('C:/Users/dispe/Downloads').glob(f'Практическая работа №{i}.*.pdf') if any(s in p.name for s in ['Асинхронная','Конфигурация','DataTable']))
    shutil.copy2(pdf,path/'Условие.pdf')
    (path/'.gitignore').write_text('bin/\nobj/\n',encoding='utf-8')
    if i==7:
        (path/'appsettings.Development.json').write_text(json.dumps({'Application':{'Title':'Консоль кофейни — локальная разработка'}},ensure_ascii=False,indent=2),encoding='utf-8')
print('Подготовлены проекты 6–8, конфигурации и условия.')
