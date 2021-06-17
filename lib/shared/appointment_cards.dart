import 'package:flutter/material.dart';


class Appointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                    ),
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0,),
            Row(
              children: [
                Icon(
                  Icons.phone,
                ),
                Text(
                  'Number',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(onPressed: () {} ,
                  child: Text(
                      'Reschedule'
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ElevatedButton(onPressed: () {} ,
                    child: Text(
                        'Done'
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(width: 10.0,),
                ),
                Expanded(
                  flex: 5,
                  child: ElevatedButton(onPressed: () {} ,
                    child: Text(
                        'Cancel'
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}