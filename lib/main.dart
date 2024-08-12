import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movie App',
        initialRoute: '/',
        routes: {
          '/': (context) => MovieListPage(),
          '/details': (context) => MovieDetailPage(),
        },
      ),
    ),
  );
}

class Movie {
  final String title;
  final String? overview;
  final String? posterUrl;
  final int? id;

  Movie({
    required this.title,
    this.overview,
    this.posterUrl,
    this.id,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterUrl: 'https://image.tmdb.org/t/p/w185${json['poster_path']}' ?? '',
    );
  }
}

class NewsState extends ChangeNotifier {
  List<Movie> _allMovies = [];
  List<Movie> _favoriteMovies = [];
  Movie? _selectedMovie;

  List<Movie> get allMovies => _allMovies;
  List<Movie> get favoriteMovies => _favoriteMovies;
  Movie? get selectedMovie => _selectedMovie;

  set allMovies(List<Movie> movies) {
    _allMovies = movies;
    notifyListeners();
  }

  /*addFavorite(Movie movie) {
    _favoriteMovies.add(movie);
    notifyListeners();
  }

  removeFavorite(Movie movie) {
    _favoriteMovies.remove(movie);
    notifyListeners();
  }*/

  setSelectedMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  Future<void> fetchPopularMovies() async {
    final apiKey = '4811aced47764c63946203edefe3e5bb';
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/trending/all/day?api_key=07f8b7653bcc374f6953bdd8a20cba9c'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final moviesList = (jsonData['results'] as List).map((movie) => Movie.fromJson(movie)).toList();
      allMovies = moviesList;
    } else {
      throw Exception('Failed to load popular movies');
    }
  }
}

class MovieListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsState = Provider.of<NewsState>(context, listen: false);
    newsState.fetchPopularMovies();

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text(' Remon Movies App'),
        actions: [Icon(Icons.search)],
      ),
      body: Consumer<NewsState>(
        builder: (context, newsState, _) {
          if (newsState.allMovies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: newsState.allMovies.length,
              itemBuilder: (context, index) {
                final movie = newsState.allMovies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () {
                    newsState.setSelectedMovie(movie);
                    Navigator.pushNamed(context, '/details');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MovieDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsState = Provider.of<NewsState>(context);
    final selectedMovie = newsState.selectedMovie;

    if (selectedMovie == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Movie Detail'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(selectedMovie.title),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (selectedMovie.posterUrl != null)
            ClipRRect(
            borderRadius: BorderRadius.circular(8),
        child: Image.network(
          selectedMovie.posterUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    SizedBox(height: 10),
    Text(
    selectedMovie.title,
    style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 10),
    Text(
    selectedMovie.overview ?? 'No overview available.',
    style: const TextStyle(fontSize: 16),
    ),
    ],
    ),
    ),
    );
    }
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  MovieCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (movie.posterUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.posterUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 10),
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}