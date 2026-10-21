from pathlib import Path
import shutil

root=Path('ADD.NET/Лабораторные работы')
folders=['ПР_01_Подключение','ПР_02_SqlCommand','ПР_03_Параметры','ПР_04_SqlDataReader','ПР_05_Транзакции']
for i, folder in enumerate(folders,1):
    path=root/folder
    (path/f'AdoNetPractice{i:02}.csproj').write_text('<Project Sdk="Microsoft.NET.Sdk" />\n',encoding='utf-8')
    source=next(Path('C:/Users/dispe/Downloads').glob(f'Практическая работа №{i}.*.pdf'))
    shutil.copy2(source,path/'Условие.pdf')
source=Path('Теория баз данных Microsoft SQL Server/Лабораторные и Практические работы/ЛАБ_Комплексная_SQL_Server/Мингазов_Ахнаф')
dest=root/'ЛАБ_06_Комплексная_SQL_Server'
dest.mkdir(exist_ok=True)
for name in ['CollegeDB_dump.sql','Mingazov_Akhnaf_sqlserver.sql']:
    shutil.copy2(source/name,dest/name)
shutil.copy2(Path('C:/Users/dispe/Downloads/Лабораторная работа. Комплексная работа с MS SQL Server.pdf'),dest/'Условие.pdf')
print('Созданы пять проектов, скопированы шесть условий и комплексная SQL-работа.')
