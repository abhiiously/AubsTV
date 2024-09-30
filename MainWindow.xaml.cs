using System;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;

namespace AubsTV
{
    public partial class MainWindow : Window
    {
        private ObservableCollection<string> playlist = new ObservableCollection<string>();

        public MainWindow()
        {
            InitializeComponent();
            PlaylistListBox.ItemsSource = playlist;
        }

        private void AddToPlaylistButton_Click(object sender, RoutedEventArgs e)
        {
            string url = UrlTextBox.Text;
            if (!string.IsNullOrEmpty(url))
            {
                playlist.Add(url);
                UrlTextBox.Clear();
            }
            else
            {
                MessageBox.Show("Please enter a valid URL.");
            }
        }

        private void PlayButton_Click(object sender, RoutedEventArgs e)
        {
            if (MediaPlayer.Source != null)
            {
                MediaPlayer.Play();
            }
            else if (PlaylistListBox.SelectedItem != null)
            {
                PlaySelected();
            }
            else
            {
                MessageBox.Show("Please select a stream from the playlist.");
            }
        }

        private void PauseButton_Click(object sender, RoutedEventArgs e)
        {
            MediaPlayer.Pause();
        }

        private void StopButton_Click(object sender, RoutedEventArgs e)
        {
            MediaPlayer.Stop();
        }

        private void VolumeSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            MediaPlayer.Volume = e.NewValue;
        }

        private void PlaylistListBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (PlaylistListBox.SelectedItem != null)
            {
                PlaySelected();
            }
        }

        private void PlaySelected()
        {
            string selectedUrl = PlaylistListBox.SelectedItem as string;
            if (!string.IsNullOrEmpty(selectedUrl))
            {
                try
                {
                    MediaPlayer.Source = new Uri(selectedUrl);
                    MediaPlayer.Play();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error playing stream: {ex.Message}");
                }
            }
        }
    }
}