using System;

class Program
{
    static void Main(string[] args)
    {
        string secretPassword = "admin";
        string secretLogin = "admin";
        string inputPassword = "";
        string inputLogin = "";
        

        
        while (inputLogin !=secretLogin || inputPassword != secretPassword) {
            Console.WriteLine("Введите логине :");
            inputLogin = Console.ReadLine();
            Console.WriteLine("Введите пароль: ");
            inputPassword = Console.ReadLine();
            if (inputLogin != secretLogin) {
                Console.WriteLine("Неверный логин");
            }
            if (inputPassword != secretPassword) {
                Console.WriteLine("Неверный пароль");
            }
        }
        Console.WriteLine("Вы вошли в аккаут!");

    
        

        
    }
    static void sss(int size){
        
        


    }
  



}
