from pathlib import Path
import os,subprocess,json,uuid
root=Path('ADD.NET/Лабораторные работы').resolve()
logs=Path('tmp/ado_678_verification');logs.mkdir(exist_ok=True)
server=r'(localdb)\CodexSqlPractice'
database='Ado678_Check_'+uuid.uuid4().hex[:8]
def sql(query):
    p=subprocess.run(['sqlcmd','-S',server,'-E','-C','-b','-f','65001','-h','-1','-W','-m','1','-Q','SET NOCOUNT ON; '+query],capture_output=True,encoding='utf-8',errors='replace',timeout=30)
    assert p.returncode==0,p.stdout+p.stderr
    return p.stdout.strip()
sql(f'CREATE DATABASE [{database}];')
for table in ['categories','products','customers','orders']:
    sql(f'SELECT * INTO [{database}].dbo.[{table}] FROM coffee_shop.dbo.[{table}];')
connection=f'Server={server};Database={database};Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=2'
env=os.environ.copy();env['ConnectionStrings__CoffeeShop']=connection
count=0
def app(number,inputs,name,overrides=None,expected=0):
    global count
    folder=next(root.glob(f'ПР_{number:02}_*'))
    dll=folder/'bin/Debug/net10.0'/f'AdoNetPractice{number:02}.dll'
    settings=env.copy();settings.update(overrides or {})
    run=subprocess.run(['dotnet',str(dll)],input=inputs,env=settings,capture_output=True,encoding='utf-8',errors='replace',timeout=40)
    (logs/(name+'.log')).write_text(run.stdout+'\nSTDERR:\n'+run.stderr,encoding='utf-8')
    assert run.returncode==expected,(name,run.stdout,run.stderr)
    count+=1
    return run.stdout
before=sql(f'USE [{database}]; SELECT STRING_AGG(CONCAT(id,\':\',is_available,\':\',price),\';\') WITHIN GROUP(ORDER BY id) FROM products;')
out=app(6,'1\n2\n3\nКап\n3\nНетТакогоТовара\n4\n5\n1\n0\n5\n1\n1\n5\n999999\n1\n6\n7\n200\n7\n999999\n8\n1\n8\n999999\n5\nabc\n0\n','06_async_menu')
assert 'Капучино' in out and 'Количество товаров: 6' in out and 'Клиентов: 3' in out
assert 'Товары не найдены.' in out and 'Товар не найден.' in out and 'Заказы клиента не найдены.' in out and 'Заказ №1' in out
after=sql(f'USE [{database}]; SELECT STRING_AGG(CONCAT(id,\':\',is_available,\':\',price),\';\') WITHIN GROUP(ORDER BY id) FROM products;')
assert before==after
out=app(7,'1\n2\n3\n4\nКап\n4\nНетТакогоТовара\n5\n0\n','07_configuration_menu')
assert database in out and 'Товаров: 6' in out and 'Клиентов: 3' in out and 'Заказов: 2' in out and 'локальная разработка' in out
assert 'Товары не найдены.' in out and 'руб.' in out
out=app(7,'3\n5\n0\n','07_hide_prices',{'Application__ShowPrices':'false','Application__Title':'Название из окружения'})
assert 'руб.' not in out and 'Название из окружения' in out and 'Показывать цены: False' in out
out=app(7,'0\n','07_invalid_bool',{'Application__ShowPrices':'нет'},expected=1)
assert 'ShowPrices должен быть true или false' in out
out=app(7,'1\n0\n','07_invalid_server',{'ConnectionStrings__CoffeeShop':'Server=tcp:127.0.0.1,1;Database=coffee_shop;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=1'})
assert 'Ошибка SQL Server:' in out
path=next(root.glob('ПР_07_*/bin/Debug/net10.0/appsettings.json'))
original=path.read_bytes()
try:
    config=json.loads(original);config['ConnectionStrings']['Demo']=config['ConnectionStrings'].pop('CoffeeShop')
    path.write_text(json.dumps(config,ensure_ascii=False),encoding='utf-8')
    # Убираем только переменную подключения, чтобы проверить отсутствие ключа JSON.
    saved=env.pop('ConnectionStrings__CoffeeShop')
    try:
        out=app(7,'','07_missing_key',expected=1)
        assert 'CoffeeShop не найдена' in out
    finally:env['ConnectionStrings__CoffeeShop']=saved
finally:path.write_bytes(original)
out=app(8,'2\n1\n2\n3\n4\n5\n1\n5\n999999\n6\n1\n999\n7\n1\n8\n9\n10\n6\nabc\n1\n2\n0\n','08_memory_catalog')
assert 'Сначала загрузите данные' in out and 'RowState: Modified' in out and 'совпадают: False' in out
assert 'Напитки: 4' in out and 'Десерты: 2' in out and 'Доступных товаров: 5' in out and 'Категория не найдена.' in out
assert sql(f'USE [{database}]; SELECT price FROM products WHERE id=1;')=='120.00'
# Пустой набор: изменяем только отдельную проверочную базу.
sql(f'USE [{database}]; DELETE FROM products; DELETE FROM categories;')
out=app(8,'1\n2\n3\n9\n10\n0\n','08_empty_tables')
assert 'товаров: 0' in out and 'Товары не найдены.' in out and 'Категории не найдены.' in out
out=app(6,'1\n6\n0\n','06_empty_catalog')
assert 'Товары не найдены.' in out and 'Количество товаров: 0' in out
report={'status':'passed','console_scenarios':count,'server':server,'verification_database':database,'working_coffee_shop_modified':False}
(logs/'result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
