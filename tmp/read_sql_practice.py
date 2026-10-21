import sys
from pathlib import Path
sys.path.insert(0, r'C:\project\DZ_PRACTICa\tmp\pdf_dependencies')
from pypdf import PdfReader
for p in Path('C:/Users/dispe/Downloads').glob('Практическая работа №*.pdf'):
    print('\nFILE:',p.name)
    reader=PdfReader(p)
    for i,page in enumerate(reader.pages,1):
        print(f'\nPAGE {i}\n{page.extract_text()}')
