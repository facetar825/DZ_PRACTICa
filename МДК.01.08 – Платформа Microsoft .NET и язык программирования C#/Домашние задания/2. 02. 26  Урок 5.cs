using System;
using System.Linq;

class Program
{
    string[] word = new string[0];
    string[] hidden = new string[0]; 
    int live = 5;

    void setWord()
    {
        Console.WriteLine("Введите количество букв: ");
        int size = Convert.ToInt32(Console.ReadLine());

        for (int i = 0; i < size; i++)
        {
            Console.WriteLine($"Введи {i + 1} букву");
            string w = Console.ReadLine();
            word = word.Append(w).ToArray();
        }

     
        hidden = new string[size];
        for (int i = 0; i < size; i++)
        {
            hidden[i] = "_";
        }
    }

    void secretWord()
    {
        do
        {
            Console.WriteLine($"Жизней: {live}");
            Console.WriteLine($"Слово: {string.Join(" ", hidden)}"); 
            Console.Write("Введите букву: ");
            string buk = Console.ReadLine();

            if (word.Contains(buk))
            {
                
                for (int i = 0; i < word.Length; i++)
                {
                    if (word[i] == buk)
                    {
                        hidden[i] = buk;
                    }
                }
                Console.WriteLine("Есть такая буква");

             
                if (!hidden.Contains("_"))
                {
                    Console.WriteLine($"\nПОБЕДА! Слово: {string.Join("", word)}");
                    break;
                }
            }
            else
            {
                live--;
                Console.WriteLine("Нет такой буквы");
            }

        } while (live > 0);

        if (live == 0)
        {
            Console.WriteLine($"Ты проиграл а слово было: {string.Join("", word)}");
        }
    }

    static int Main(String[] args)
    {
        Program program = new Program();
        program.setWord();
        program.secretWord();

        return 0;
    }
}