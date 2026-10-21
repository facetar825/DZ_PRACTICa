from pathlib import Path
import subprocess,os,re,json,uuid

root=Path('ADD.NET/Лабораторные работы').resolve()
logs=Path('tmp/ado_labs_verification');logs.mkdir(exist_ok=True)
server=r'(localdb)\CodexSqlPractice'
suffix=uuid.uuid4().hex[:8]
coffee='coffee_shop_Check_'+suffix
college='CollegeDB_Check_'+suffix
env=os.environ.copy()
env['ConnectionStrings__CoffeeShop']=f'Server={server};Database={coffee};Integrated Security=True;Encrypt=True;TrustServerCertificate=True'

def sql(query=None,file=None):
    args=['sqlcmd','-S',server,'-E','-C','-b','-f','65001','-h','-1','-W','-m','1']
    args+=['-Q','SET NOCOUNT ON; '+query] if query is not None else ['-i',str(file)]
    result=subprocess.run(args,capture_output=True,encoding='utf-8',errors='replace',timeout=45)
    if result.returncode:raise RuntimeError(result.stdout+result.stderr)
    return result.stdout.strip()

def scalar(query):return sql('USE ['+coffee+']; '+query)

def app(number,inputs,name):
    folder=next(root.glob(f'ПР_{number:02}_*'))
    dll=folder/'bin/Debug/net10.0'/f'AdoNetPractice{number:02}.dll'
    run=subprocess.run(['dotnet',str(dll)],input=inputs,env=env,capture_output=True,encoding='utf-8',errors='replace',timeout=45)
    (logs/(name+'.log')).write_text(run.stdout+'\nSTDERR:\n'+run.stderr,encoding='utf-8')
    assert run.returncode==0,(name,run.stderr)
    return run.stdout

setup=logs/'coffee_setup.sql'
setup.write_text((root/'Подготовка_coffee_shop.sql').read_text(encoding='utf-8').replace('coffee_shop',coffee),encoding='utf-8-sig')
sql(file=setup)

out=app(1,'','01_connection')
assert coffee in out and 'Количество товаров: 6' in out and 'Минимальная цена: 120' in out

out=app(2,'1\n2\n3\n4\n5\n7\n8\n9\n10\n11\n0\n','02_commands')
assert 'Добавлено строк: 1' in out and 'Удалено строк: 1' in out and 'Доступных товаров: 5' in out
assert scalar('SELECT COUNT(*) FROM products')=='6'

out=app(3,"1\n1\n1\n999999\n2\nКапучино\n2\n\u0027 OR 1=1--\n6\n200\n7\n200\n8\nИван\n0\n",'03_search_and_injection')
assert 'Капучино' in out and 'Записи не найдены.' in out and 'Количество: 2' in out
newid=int(scalar("SELECT CONVERT(int,IDENT_CURRENT('products'))+1"))
out=app(3,f'3\nПроверочный латте\n1\n245,50\n4\n{newid}\n260\n1\n{newid}\n5\n{newid}\n1\n{newid}\n4\n999999\n123\n0\n','03_crud')
assert 'Добавлено строк: 1' in out and ('260,00' in out or '260.00' in out)
assert scalar('SELECT COUNT(*) FROM products')=='6'
assert 'Изменено строк: 0' in out

out=app(4,'1\n2\n1\n2\n999999\n3\nКап\n3\nНетТакогоТовара\n4\n5\n6\n7\n200\n7\n999999\n8\nИван\n9\nВыдан\n9\nНетТакогоСтатуса\n10\n0\n','04_reader')
assert 'Не указан' in out and 'Иван Петров' in out and 'Записи не найдены.' in out and 'Капучино' in out

prices=scalar("SELECT STRING_AGG(CONCAT(id,':',price),';') WITHIN GROUP(ORDER BY id) FROM products")
out=app(5,'2\n1\n999\n2\n888\n0\n','05_price_rollback')
assert 'ROLLBACK' in out and scalar("SELECT STRING_AGG(CONCAT(id,':',price),';') WITHIN GROUP(ORDER BY id) FROM products")==prices
out=app(5,'1\n1\n125\n999999\n145\n0\n','05_missing_second_product')
assert 'ROLLBACK' in out and scalar("SELECT STRING_AGG(CONCAT(id,':',price),';') WITHIN GROUP(ORDER BY id) FROM products")==prices
out=app(5,'1\n1\n125\n2\n145\n0\n','05_price_commit')
assert 'COMMIT: обе цены' in out and scalar('SELECT price FROM products WHERE id=1')=='125.00'
before=scalar('SELECT COUNT(*) FROM orders')
out=app(5,'5\n1\n1\n2\n0\n','05_order_rollback')
assert 'ROLLBACK' in out and scalar('SELECT COUNT(*) FROM orders')==before
out=app(5,'4\n1\n1\n2\n999999\n1\n0\n','05_invalid_second_item')
assert 'ROLLBACK' in out and scalar('SELECT COUNT(*) FROM orders')==before
out=app(5,'4\n1\n1\n2\n3\n1\n9\n0\n','05_two_items_commit')
order=int(re.search(r'заказ №(\d+) создан',out).group(1))
assert scalar(f'SELECT COUNT(*) FROM order_items WHERE order_id={order}')=='2'
assert '440,00' in out or '440.00' in out

nextorder=int(scalar("SELECT CONVERT(int,IDENT_CURRENT('orders'))+1"))
count=scalar('SELECT COUNT(*) FROM orders')
out=app(5,f'3\n1\n1\n2\n7\n{nextorder}\n9\n6\n{nextorder}\n0\n','05_cancel_rollback_and_commit')
assert 'Тестовая ошибка отмены' in out and 'ROLLBACK' in out and f'заказ {nextorder} и его позиции (1) удалены' in out
assert scalar('SELECT COUNT(*) FROM orders')==count
assert scalar(f'SELECT COUNT(*) FROM order_items WHERE order_id={nextorder}')=='0'
out=app(5,'6\n1\n0\n','05_protect_existing_order')
assert 'Можно отменять только тестовый заказ' in out
for number,inputs in [(3,'1\nabc\n0\n'),(4,'7\n-10\n0\n'),(5,'3\n1\n1\n0\n0\n')]:
    assert 'Ошибка:' in app(number,inputs,f'{number:02}_invalid_input')

complexroot=root/'ЛАБ_06_Комплексная_SQL_Server'
setup=logs/'college_setup.sql'
setup.write_text((complexroot/'CollegeDB_dump.sql').read_text(encoding='utf-8-sig').replace('CollegeDB',college),encoding='utf-8-sig')
sql(file=setup)
solution=logs/'college_solution.sql'
solution.write_text((complexroot/'Mingazov_Akhnaf_sqlserver.sql').read_text(encoding='utf-8-sig').replace('USE CollegeDB;','USE '+college+';'),encoding='utf-8-sig')
for i in (1,2):
    (logs/f'06_complex_run{i}.log').write_text(sql(file=solution),encoding='utf-8')
result=sql(f'USE [{college}]; SELECT COUNT(*) FROM college.StudentRating; SELECT COUNT(*) FROM college.student_changes; SELECT average_grade FROM college.students WHERE id=1;')
assert result.split()==['10','0','4.70'],result
report={'server':server,'coffee_verification_database':coffee,'college_verification_database':college,'status':'passed','console_scenarios':16,'complex_runs':2}
(logs/'result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
