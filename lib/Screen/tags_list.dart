import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/db/DbHelper.dart';
import 'package:sqflite/sqflite.dart';

class TagsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TagsListState();
  }
}

class TagsListState extends State<TagsList> {
  DbHelper databaseHelper = DbHelper();

  TextEditingController tagController = new TextEditingController();
  TextEditingController editTagController = new TextEditingController();

  List<Tag> tagsList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    if (tagsList == null) {
      tagsList = List<Tag>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(
          Icons.arrow_back),
        onPressed: () {
          moveToLastScreen();
        }
    ),
        title: Text('Gestion des libellés'),
      ),
      body: new Column(
        children: <Widget>[
          new TextField(
            controller: tagController,
            style: textStyle,
            decoration: InputDecoration(
                labelText: 'Ajouter un libellé...',
                labelStyle: textStyle,
                suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){
                      // Ajoute l'item dans la liste si la longueur du texte est plus grand que 0
                      if(tagController.text.length > 0) {
                        _add(context, new Tag(tagController.text));
                        tagController.clear();
                        updateListView();
                      }
                    }
                )
            ),
          ),
          new Expanded(
              child: getTagsListView()
          )
        ],
      )
    );
  }

  ListView getTagsListView() {
    return ListView.builder(
      itemCount: this.tagsList.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: Icon(Icons.label_outline ,color: Theme.of(context).primaryColor,),
            title: Text(this.tagsList[position].libelle,
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  onTap: () {
                    //Action pour la modification
                    _showEditTodoItem(context, this.tagsList[position]);
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    _delete(context, tagsList[position]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Méthode qui permet la modification d'un tag
  void _showEditTodoItem(BuildContext context, Tag tag){
    editTagController.text = tag.libelle;
    AlertDialog alertDialog = AlertDialog(
      title: Text("Modification d'un libellé"),
      content: Container(
          height: 100.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: TextField(
            controller: editTagController,
            decoration: InputDecoration(
                labelText: 'Modifier un libellé...',
                suffixIcon: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){
                      setState(() {
                        tag.libelle = editTagController.text;
                        _updateTag(tag);

                        Navigator.pop(context);
                      });

                    }
                )
            ),
          )
      ),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  // Méthode qui permet de mettre à jour un tag
  void _updateTag(Tag tag) async {
    int res = await databaseHelper.updateTag(tag);
    if (res != 0) {
      //_showSnackBar(context, 'Item supprimé avec succès');
    }
  }

  void _delete(BuildContext context, Tag tag) async {
    int result = await databaseHelper.deleteTag(tag.numId);
    if (result != 0) {
      //_showSnackBar(context, 'Libellé supprimé avec succès');
      updateListView();
    }
  }

  void _add(BuildContext context, Tag tag) async {
    int result = await databaseHelper.insertTag(tag);
    if (result != 0) {
      //_showSnackBar(context, 'Libellé ajouté avec succès');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initDatabase();
    dbFuture.then((database) {
      Future<List<Tag>> tagsListFuture = databaseHelper.getTagsList();
      tagsListFuture.then((tagList) {
        setState(() {
          this.tagsList = tagList;
        });
      });
    });
  }
}