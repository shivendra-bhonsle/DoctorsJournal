class Patient{
  //inal String pid;
  final String name;
  final String phoneno;
  final int age;
  final String nextAppo;
  final String lastAppo;
  final String description;

  Patient({
    //required this.pid,
    required this.name,
    required this.phoneno,
    required this.age,
    required this.nextAppo,
    required this.lastAppo,
    required this. description
  });

  factory Patient.initialData(){
    return Patient( name: 'name',
        phoneno: 'phoneno', age: 0,
        nextAppo: 'nextAppo',
        lastAppo: 'lastAppo', description: 'description');
  }

}