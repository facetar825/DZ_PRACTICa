import sys
from pathlib import Path
sys.path.insert(0, r'C:\project\DZ_PRACTICa\tmp\pdf_dependencies')
from pypdf import PdfReader
for i in [6,7,8]:
    for p in Path('C:/Users/dispe/Downloads').glob(f'Практическая работа №{i}.*.pdf'):
        if any(x in p.name for x in ['Асинхронная','Конфигурация','DataTable']):
            text='\n'.join(page.extract_text() or '' for page in PdfReader(p).pages).replace('\x00','')
            Path(f'tmp/practice{i}.txt').write_text(text,encoding='utf-8')
            print('\nFILE:',p.name,'\n',text)
