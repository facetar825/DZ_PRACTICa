public class MedicalRecord
{
    public DateTime DateTime { get; set; }

    public int Systolic { get; set; }

    public int Diastolic { get; set; }

    public int Pulse { get; set; }

    public double Sugar { get; set; }

    public string MealType { get; set; }

    public string Comment { get; set; }


    public string ToolTipText
    {
        get
        {
            return
            $"Дата: {DateTime}\n" +
            $"Давление: {Systolic}/{Diastolic}\n" +
            $"Пульс: {Pulse}\n" +
            $"Сахар: {Sugar}\n" +
            $"Приём пищи: {MealType}\n" +
            $"Комментарий: {Comment}";
        }
    }
    public string Info
    {
        get
        {
            return
            $"Дата: {DateTime}\n" +
            $"Давление: {Systolic}/{Diastolic}\n" +
            $"Пульс: {Pulse}\n" +
            $"Сахар: {Sugar}\n" +
            $"Еда: {MealType}\n" +
            $"Комментарий: {Comment}";
        }
    }
}