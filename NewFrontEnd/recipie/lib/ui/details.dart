import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:recipes/helper/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../podo/category.dart';
import '../providers/details_provider.dart';
import '../widgets/book_list_item.dart';

// ignore: must_be_immutable
class Details extends StatefulWidget {
  final Entry entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  Details({
    Key key,
    @required this.entry,
    @required this.imgTag,
    @required this.titleTag,
    @required this.authorTag,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  BannerAd _bannerAd;

  InterstitialAd _interstitialAd;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        // adUnitId: "ca-app-pub-5534506225496412/8754411628",
        listener: (MobileAdEvent event) {
          print('interstitial event: $event');
        });
  }

  BannerAd createBannerAdd() {
    return BannerAd(
        // adUnitId: BannerAd.testAdUnitId,
        adUnitId: "ca-app-pub-5534506225496412/5814221815",
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Bnner Event: $event');
        });
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 5), () {
      _bannerAd?.show(
        anchorOffset: 80.0,
        anchorType: AnchorType.bottom,
      );
    });
    return Consumer<DetailsProvider>(
      builder: (BuildContext context, DetailsProvider detailsProvider,
          Widget child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  if (detailsProvider.faved) {
                    detailsProvider.removeFav();
                  } else {
                    detailsProvider.addFav();
                  }
                },
                icon: Icon(
                  detailsProvider.faved
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: detailsProvider.faved
                      ? Colors.red
                      : Theme.of(context).iconTheme.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  Share.share(
                    "I am Reading ${widget.entry.title}. on ${Constants.appName}. \n\n Download App @ https://play.google.com/store/apps/details?id=${Constants.appPackage}",
                    subject: '${widget.entry.title}',
                  );
                },
                icon: Icon(
                  Icons.share,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    child: Hero(
                      tag: widget.imgTag,
                      child: CachedNetworkImage(
                        imageUrl: "${widget.entry.coverImage}",
                        placeholder: (context, url) => Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.close),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: widget.titleTag,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          "${widget.entry.title.replaceAll(r"\", "")}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    widget.entry.category == null
                        ? SizedBox()
                        : Container(
                            height: 25,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.entry.category.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                String cat = widget.entry.category[index];
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  margin: EdgeInsets.only(right: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).accentColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$cat',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context).textTheme.caption.color,
              ),
              Html(
                data: "${widget.entry.summary}",
                // backgroundColor: Theme.of(context).backgroundColor,
                // linkStyle: const TextStyle(
                //   color: Colors.redAccent,
                // ),
                onLinkTap: (url) {},
                onImageTap: (src) {},
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Related Dishes!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: [0.015, 0.015],
                    colors: [
                      Color.fromRGBO(209, 2, 99, 1),
                      Theme.of(context).backgroundColor
                    ],
                  ),
                ),
              ),
              Divider(
                color: Theme.of(context).textTheme.caption.color,
              ),
              SizedBox(
                height: 10,
              ),
              detailsProvider.loading
                  ? Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: detailsProvider.related.feed.entry.length,
                      itemBuilder: (BuildContext context, int index) {
                        Entry entry = detailsProvider.related.feed.entry[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: BookListItem(
                            img: entry.coverImage,
                            title: entry.title,
                            author: entry.category[0],
                            desc: entry.summary
                                .replaceAll(RegExp(r"<[^>]*>"), ''),
                            entry: entry,
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-5534506225496412~3537743967');
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
