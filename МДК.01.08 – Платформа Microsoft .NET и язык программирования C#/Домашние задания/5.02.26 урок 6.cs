using System;      
using System.Linq;
namespace lesson_7_8_functions

{
    internal class Program
    {
        static void Main(string[] args)
        {
            string[] users = new string[20];

            while (true)
            {
                Console.WriteLine("1. добавить пользователя \n " +
                    "2. Удвлить пользвателя \n" +
                    "3. изменить пользователя \n" +
                    "4. показать пользователей");

                Console.Write("Напишите номер действия: ");
                int action = Convert.ToInt32(Console.ReadLine());

                switch (action)
                {
                    case 1:
                        users = AddUser(users);
                        break;
                    case 2:
                        users = RemoveUser(users);
                        break;
                    case 3:
                        ChangeUser(users);
                        break;
                    case 4:
                        ShowUsers(users);
                        break;
                    default:
                        Console.WriteLine("не верная команда ");
                        break;

                }
                Console.ReadKey();
                Console.Clear();
            }
        }
        static string[] AddUser(string[] users) 
        {
            Console.WriteLine("Добавление пользователя ");
            Console.Write("Введите имя нового пользователя: ");
            string newUser = Console.ReadLine();

            for(int i = 0; i < users.Length; i++)
            {
                if (string.IsNullOrEmpty(users[i]))
                {
                    users[i] = newUser;
                    break;
                }
            }
            Console.WriteLine("Пользователь добавлен ");
            return users;
        }
        //Тут можно было сделать просто по индексу
        //но легче было скопировать код из удалине и зминить пару строк 
        static string[] ChangeUser(string[] users)
        {
            Console.WriteLine("Добавление пользователя");
            Console.WriteLine("Список пользователей: ");
            ShowUsers(users);

            Console.Write("Введите имя котоорого хотите изменить пользователя: ");
            string changerUser = Convert.ToString(Console.ReadLine());
            if (users.Contains(changerUser))
            {
                for (int i = 0; i < users.Length; i++)
                {
                    if (users[i] == changerUser)
                    {
                        Console.WriteLine("Введи на что хочешь изменить: ");
                        string changer = Convert.ToString(Console.ReadLine());
                        users[i] = changer;
                        Console.WriteLine("Юзер изменён: ");
                        break;
                    }
                }
            }
            else
            {
                Console.WriteLine("Пользователя нет ");
            }
            return users;

        }

        static string[] RemoveUser(string[] users) 
        {
            Console.WriteLine("Удаление пользователя: ");

            Console.WriteLine("Список пользователей: ");
            ShowUsers(users);

            Console.Write("Введите имя удаляемого пользователя: ");
            string removeUser = Console.ReadLine();
            if (users.Contains(removeUser))
            {
                for (int i = 0; i < users.Length; i++)
                { 
                    if (users[i] == removeUser)
                    {
                        users[i] = string.Empty;
                        Console.WriteLine("польхователь удален");
                        break;
                    }
                }
            }
            else 
            {
                Console.WriteLine("Пользователя нет ");
            }
            return users;
        
        }

        static void ShowUsers(string[] users) 
        {
            Console.WriteLine("Отображение пользователей ");
            int count = 0;
            foreach (string user in users) 
            {
                count++;
                Console.WriteLine($"{count}. {user}");
            }
        
        }

    }
}