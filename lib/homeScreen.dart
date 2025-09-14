import 'package:flutter/material.dart';
import 'package:note_app/mongo.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  List<dynamic> notes = [];
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async{
    final data = await MongoService.getNotes();
    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes App'), backgroundColor: Colors.redAccent),
      
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: isLoading? Center(child: CircularProgressIndicator()): 
        notes.isNotEmpty? ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context,index){
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Text("${index+1}"),
              ),
              title: Text(notes[index]["title"]),
              subtitle: Text(notes[index]["description"]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: (){
                      String id = notes[index]["id"];
                      String title = notes[index]["title"];
                      String description = notes[index]["description"];
                      showModalBottomSheet(context: context, builder: (BuildContext context){
                        return BottomView(isEdit: true,id: id,title: title,description: description, loadNotes: loadNotes);
                      });
                    },
                    icon: Icon(Icons.edit)
                  ),
                  SizedBox(width: 10,),
                  IconButton(onPressed: ()async {await MongoService.deleteNote(notes[index]["id"]);loadNotes();},icon: Icon(Icons.delete)),
                ],
              ),
            );
          },
        ):
        Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("assets/images/note.png"), height: 200, width: 200,),
            SizedBox(height: 10),
            Text("No Notes Found!"),
          ],
        ))
      ),
    
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(inverted: false,),
        elevation: 20,
        notchMargin: 20.0,
        color: Colors.redAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home, color: Colors.white), onPressed: () {}),
            IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () {
          showModalBottomSheet(context: context, builder: (BuildContext context){
            return BottomView(isEdit: false,loadNotes: loadNotes);
          });
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class BottomView extends StatefulWidget {
  BottomView({
    super.key,
    required this.isEdit,
    this.id,
    this.title,
    this.description,
    required this.loadNotes
  });

  final bool isEdit;
  final String? id;
  final String? title;
  final String? description;
  final Function loadNotes;

  @override
  State<BottomView> createState() => _BottomViewState();
}

class _BottomViewState extends State<BottomView> {
  late TextEditingController titleCtrl;
  late TextEditingController descriptionCtrl; 

  @override
  void initState(){
    super.initState();
    titleCtrl = TextEditingController(text: widget.title ?? "");
    descriptionCtrl = TextEditingController(text: widget.description ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.isEdit? "Update Note":"Add Note", textAlign: TextAlign.center, style: TextStyle(fontSize: 40,color: Colors.black),),
            SizedBox(height: 30),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(hintText: "Enter Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionCtrl,
              decoration: InputDecoration(hintText: "Enter Description"),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100,50),
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                textStyle: TextStyle(color: Colors.black, fontSize: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                side: BorderSide(color: Colors.black,width: 1.0)
              ),
              onPressed: () {
                if(!widget.isEdit){
                  MongoService.addNote(titleCtrl.text.trim(), descriptionCtrl.text.trim());
                }
                else{
                  MongoService.updateNote(widget.id!, titleCtrl.text.trim(), descriptionCtrl.text.trim());
                }
                Navigator.pop(context);
                widget.loadNotes();
              }, 
              child: Text(widget.isEdit? "Update":"Save"),
            ),
          ]
        ),
      ),
    );
  }
  
}
