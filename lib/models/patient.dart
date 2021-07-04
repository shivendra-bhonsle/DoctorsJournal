class Patient{
  final String pid;
  final String name;
  final String phoneno;
  final int age;
  final double weight;
  final String nextAppo;
  final String lastAppo;
  final String description;

  Patient({
    required this.pid,
    required this.name,
    required this.phoneno,
    required this.age,
    required this.weight,
    required this.nextAppo,
    required this.lastAppo,
    required this. description
  });

  // factory Patient.initialData(){
  //   return Patient(pid: 'pid', name: 'name',
  //       phoneno: 'phoneno', age: 0,
  //       weight: 0.0, nextAppo: 'nextAppo',
  //       lastAppo: 'lastAppo', description: 'description')
  // }

}