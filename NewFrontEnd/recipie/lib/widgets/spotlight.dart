import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../podo/category.dart';
import '../providers/details_provider.dart';
import '../providers/favorites_provider.dart';
import '../ui/details.dart';

class SpotLight extends StatefulWidget {
  final String img;
  final String title;
  final Entry entry;

  SpotLight({
    Key key,
    @required this.img,
    @required this.title,
    @required this.entry,
  }) : super(key: key);

  static final uuid = Uuid();

  @override
  _SpotLightState createState() => _SpotLightState();
}

class _SpotLightState extends State<SpotLight> {
  final String imgTag = SpotLight.uuid.v4();

  final String titleTag = SpotLight.uuid.v4();

  final String authorTag = SpotLight.uuid.v4();

  InterstitialAd _interstitialAd;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        // adUnitId: InterstitialAd.testAdUnitId,
        adUnitId: "ca-app-pub-5534506225496412/8754411628",
        listener: (MobileAdEvent event) {
          print('interstitial event: $event');
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
        ).then((v) {
          Provider.of<FavoritesProvider>(context, listen: false).getFeed();
        });
      },
      child: Container(
        width: 175.0,
        height: 280.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                height: 175.0,
                width: 280.0,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        child: Hero(
                          tag: imgTag,
                          child: CachedNetworkImage(
                            imageUrl: "${widget.img}",
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/place.png",
                              fit: BoxFit.cover,
                              height: 175.0,
                              width: 175.0,
                            ),
                            fit: BoxFit.cover,
                            height: 175.0,
                            width: 175.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, bottom: 5.0),
              child: Text(
                "${widget.title.replaceAll(r"\", "")}",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-5534506225496412~3537743967');
    _interstitialAd = createInterstitialAd()..load();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
