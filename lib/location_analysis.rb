require_relative '../config/environment'

class Analyze
  @@dist_threshold = 200
  @@word_pct_threshold = 0.7

  STOP_WORDS = [
    'a','cannot','into','our','thus','about','co','is','ours','to','above',
    'could','it','ourselves','together','across','down','its','out','too',
    'after','during','itself','over','toward','afterwards','each','last','own',
    'towards','again','eg','latter','per','under','against','either','latterly',
    'perhaps','until','all','else','least','rather','up','almost','elsewhere',
    'less','same','upon','alone','enough','ltd','seem','us','along','etc',
    'many','seemed','very','already','even','may','seeming','via','also','ever',
    'me','seems','was','although','every','meanwhile','several','we','always',
    'everyone','might','she','well','among','everything','more','should','were',
    'amongst','everywhere','moreover','since','what','an','except','most','so',
    'whatever','and','few','mostly','some','when','another','first','much',
    'somehow','whence','any','for','must','someone','whenever','anyhow',
    'former','my','something','where','anyone','formerly','myself','sometime',
    'whereafter','anything','from','namely','sometimes','whereas','anywhere',
    'further','neither','somewhere','whereby','are','had','never','still',
    'wherein','around','has','nevertheless','such','whereupon','as','have',
    'next','than','wherever','at','he','no','that','whether','be','hence',
    'nobody','the','whither','became','her','none','their','which','because',
    'here','noone','them','while','become','hereafter','nor','themselves','who',
    'becomes','hereby','not','then','whoever','becoming','herein','nothing',
    'thence','whole','been','hereupon','now','there','whom','before','hers',
    'nowhere','thereafter','whose','beforehand','herself','of','thereby','why',
    'behind','him','off','therefore','will','being','himself','often','therein',
    'with','below','his','on','thereupon','within','beside','how','once',
    'these','without','besides','however','one','they','would','between','i',
    'only','this','yet','beyond','ie','onto','those','you','both','if','or',
    'though','your','but','in','other','through','yours','by','inc','others',
    'throughout','yourself','can','indeed','otherwise','thru','yourselves'
    ]

  def self.filter_stopwords(array)
    array.delete_if {|word|
      STOP_WORDS.member?(word.downcase)
    }
  end

  def self.locations
    Location.destroy_all
    # Find posts with lat/lng + location name, put array
    relevant_posts = Post.all.select {|post| post.location_name && post.lat && post.lng}

    # For each of these
    relevant_posts.each {|post|
      # Search all other posts
      matches = relevant_posts.select {|check_post|
        match = false
        if post != check_post
          if distance([post.lat, post.lng],[check_post.lat, check_post.lng]) < @@dist_threshold
            if post_location_sig_words = filter_stopwords(post.location_name.split(" "))
              text_match_threshold = [1,(post_location_sig_words.size * @@word_pct_threshold).to_i].max
              count = 0
              post_location_sig_words.each {|word|
                count += 1 if check_post.location_name.downcase.split(" ").include? word.downcase
              }
              match = true if count >= text_match_threshold
            end
          end
        end
        match
      }
      # If result is returned,
      if matches.size > 0
        # Create new location
        l = Location.new
        l.name = post.location_name
        l.lat = post.lat
        l.lng = post.lng
        l.save
        # Add location id
        post.location_id = l.id
        post.save
        matches.each {|post|
          post.location_id = l.id
          post.save
        }
        # Delete matches
        relevant_posts.delete_if {|post| matches.include? post}
      end
    }
  end
end