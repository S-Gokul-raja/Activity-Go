import 'dart:ui';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/my_theme_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/emoji_widget.dart';
import '../my_theme.dart';

class NewActivityPage extends StatefulWidget {
  static const String routeName = '/new-activity';
  const NewActivityPage({Key? key}) : super(key: key);

  @override
  State<NewActivityPage> createState() => _NewActivityPageState();
}

class _NewActivityPageState extends State<NewActivityPage> {
  late String selectedTitle, selectedEmoji;
  TextEditingController titleController = TextEditingController();
  late Color selectedColor;
  late int selectedIndex;

  late MyThemeProvider myThemeProvider;
  late Activity? activity;
  bool isInit = false;
  late FocusNode focusNode;
  @override
  void didChangeDependencies() {
    if (!isInit) {
      setState(() {
        myThemeProvider = Provider.of<MyThemeProvider>(context, listen: false);
        activity = (ModalRoute.of(context)?.settings.arguments
            as Map<String, Activity?>)['activity'];
        selectedIndex = activity?.color ?? 1;
        selectedColor = MyTheme.colors[activity?.color ?? 1];
        selectedTitle = activity?.title ?? '';
        selectedEmoji = activity?.emoji ?? '😸';
        titleController.text = activity?.title ?? '';
        focusNode = FocusNode();
        isInit = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EmojiPicker emojiPickerWidget = EmojiPicker(
      onEmojiSelected: (_, emoji) {
        setState(() {
          selectedEmoji = emoji.emoji;
        });
        Navigator.pop(context);
      },
      config: Config(
          columns: 5,
          emojiSizeMax: 32,
          bgColor: myThemeProvider.bgColor,
          indicatorColor: myThemeProvider.fontColor,
          iconColor: Colors.grey,
          iconColorSelected: myThemeProvider.fontColor,
          progressIndicatorColor: Colors.grey,
          backspaceColor: Colors.blue,
          enableSkinTones: false,
          recentsLimit: 12,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              selectedTitle = titleController.text;
              if (selectedTitle.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: AlertDialog(
                          elevation: 5,
                          backgroundColor: myThemeProvider.bgColor,
                          title: Text(
                            "Hold up",
                            style: TextStyle(color: selectedColor),
                          ),
                          content: Text(
                            "Can't save activity: no title",
                            style: TextStyle(
                              color: myThemeProvider.fontColor,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: selectedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                return;
              }
              if (activity != null) {
                activity?.editActivity(
                  color: MyTheme.colors.indexOf(selectedColor),
                  title: selectedTitle,
                  emoji: selectedEmoji,
                );
                Navigator.of(context).pop<Map<String, dynamic>>({
                  'new': false,
                  'activity': activity,
                });
              } else {
                Activity newActivity = Activity(
                  color: MyTheme.colors.indexOf(selectedColor),
                  title: selectedTitle,
                  emoji: selectedEmoji,
                );
                Navigator.of(context).pop<Map<String, dynamic>>({
                  'new': true,
                  'activity': newActivity,
                });
              }
            },
            child: Text(
              'Save ',
              style: TextStyle(
                fontSize: MyTheme.title2.fontSize,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                activity != null ? 'Edit Activity' : 'New Activity',
                style: MyTheme.title1,
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Title & Emoji',
                style: MyTheme.title2.copyWith(),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => focusNode.requestFocus(),
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                        color: myThemeProvider.bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: myThemeProvider.fontColor,
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        left: 50,
                        top: 20,
                        bottom: 20,
                        right: 10,
                      ),
                      child: TextField(
                        cursorWidth: 3,
                        focusNode: focusNode,
                        controller: titleController,
                        cursorColor: myThemeProvider.fontColor,
                        cursorRadius: const Radius.circular(2),
                        decoration: InputDecoration.collapsed(
                          hintText: ' Enter Title Here',
                          hintStyle: MyTheme.title2.copyWith(),
                        ),
                        style: MyTheme.title2.copyWith(),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return emojiPickerWidget;
                        },
                      );
                    },
                    child: EmojiWidget(
                        emoji: selectedEmoji, color: selectedColor, size: 40),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Color',
                style: MyTheme.title2.copyWith(),
              ),
            ),
            Card(
              elevation: 0,
              color: myThemeProvider.bgColor,
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        selectedColor = MyTheme.colors[selectedIndex];
                      });
                    },
                    child: Stack(
                      children: [
                        if (index == selectedIndex)
                          Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: myThemeProvider.fontColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 2, color: myThemeProvider.fontColor),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MyTheme.colors[index],
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 2, color: myThemeProvider.fontColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
