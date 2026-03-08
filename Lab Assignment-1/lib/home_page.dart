import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<User> users = [];

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController age = TextEditingController();

  void loadUsers() async {
    final data = await DatabaseHelper.instance.getUsers();
    setState(() {
      users = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // ADD USER
  void addUser() async {

    if (name.text.isEmpty || email.text.isEmpty || age.text.isEmpty) return;

    User user = User(
      name: name.text,
      email: email.text,
      age: int.parse(age.text),
      image: "",
    );

    await DatabaseHelper.instance.insertUser(user);

    name.clear();
    email.clear();
    age.clear();

    loadUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("User added successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // UPDATE DIALOG
  void showEditDialog(User user) {

    TextEditingController nameController =
    TextEditingController(text: user.name);

    TextEditingController emailController =
    TextEditingController(text: user.email);

    TextEditingController ageController =
    TextEditingController(text: user.age.toString());

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Update User",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 10),

              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  prefixIcon: Icon(Icons.cake, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            ElevatedButton.icon(
              icon: Icon(Icons.update, color: Colors.white),
              label: Text(
                "Update",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {

                User updatedUser = User(
                  id: user.id,
                  name: nameController.text,
                  email: emailController.text,
                  age: int.parse(ageController.text),
                  image: user.image,
                );

                await DatabaseHelper.instance.updateUser(updatedUser);

                loadUsers();

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User updated successfully"),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          "User Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

            child: Column(
              children: [

                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Age",
                    prefixIcon: Icon(Icons.cake, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: addUser,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Add User",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context,index){

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                          Icons.person,
                          color: Colors.white
                      ),
                    ),

                    title: Text(
                      users[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "${users[index].email}\nAge: ${users[index].age}",
                    ),

                    isThreeLine: true,

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showEditDialog(users[index]);
                          },
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {

                            await DatabaseHelper.instance
                                .deleteUser(users[index].id!);

                            loadUsers();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("User deleted successfully"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}