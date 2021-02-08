import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../podo/category.dart';
import '../providers/details_provider.dart';
import '../ui/details.dart';

class BookCard extends StatefulWidget {
  final String img;
  final Entry entry;

  BookCard({
    Key key,
    @required this.img,
    @required this.entry,
  }) : super(key: key);

  static final uuid = Uuid();

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final String imgTag = BookCard.uuid.v4();

  final String titleTag = BookCard.uuid.v4();

  final String authorTag = BookCard.uuid.v4();
  BannerAd _bannerAd;

  InterstitialAd _interstitialAd;

  final _nativeAdController = NativeAdmobController();

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        listener: (MobileAdEvent event) {
          print('interstitial event: $event');
        });
  }

  BannerAd createBannerAdd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Bnner Event: $event');
        });
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 10), () {
      _bannerAd?.show();
    });
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.05),
              blurRadius: 2,
              offset: Offset(0, 3)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        onTap: () {
          _bannerAd?.dispose();
          _bannerAd = null;
          _interstitialAd?.show();
          Provider.of<DetailsProvider>(context, listen: false)
              .setEntry(widget.entry);
          Provider.of<DetailsProvider>(context, listen: false)
              .getFeed(widget.entry.related);
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: Details(
                entry: widget.entry,
                imgTag: imgTag,
                titleTag: titleTag,
                authorTag: authorTag,
              ),
            ),
          );
        },
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Hero(
                    tag: imgTag,
                    child: CachedNetworkImage(
                      imageUrl: "${widget.img}",
                      placeholder: (context, url) => Container(
                          height: 125,
                          width: 248,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/place.png",
                        fit: BoxFit.cover,
                        height: 125,
                        width: 248,
                      ),
                      height: 125,
                      width: 248,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 10.0,
                  bottom: 10.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Text(
                      '${widget.entry.category[0]}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                "${widget.entry.title}",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Container(
                      child: Icon(
                    Icons.date_range,
                    color: Theme.of(context).accentColor,
                    size: 12.0,
                  )),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Text("${widget.entry.published}",
                        style: TextStyle(
                          fontSize: 12,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.visibility,
                      color: Theme.of(context).accentColor,
                      size: 12.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Text("${widget.entry.newsViews}",
                        style: TextStyle(
                          fontSize: 12,
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: 'YOUR_APP_ID');
    _bannerAd = createBannerAdd()..load();
    _interstitialAd = createInterstitialAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
