import sys
from pathlib import Path
sys.path.insert(0, r'C:\project\DZ_PRACTICa\tmp\pdf_dependencies')
from pypdf import PdfReader
out=Path('tmp/ado_practice_text');out.mkdir(exist_ok=True)
for p in Path('C:/Users/dispe/Downloads').glob('*.pdf'):
    if p.name.startswith('Практическая работа №') and any(s in p.name for s in ['ADO.NET','SqlDataReader','SqlParameter','SqlCommand','подключение C#']) or p.name.startswith('Лабораторная работа. Комплексная'):
        text='\n'.join(page.extract_text() or '' for page in PdfReader(p).pages).replace('\x00','')
        (out/(p.stem+'.txt')).write_text(text,encoding='utf-8')
        print('\nFILE:',p.name,'\n',text)
