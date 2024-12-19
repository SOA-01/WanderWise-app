$(document).ready(function () {
    console.log('JavaScript loaded!');
  
    function updateProgress() {
      console.log('Sending request to /progress');
      $.ajax({
        url: '/progress',
        method: 'GET',
        success: function (data) {
          console.log('Progress data received:', data);
  
          let progress;
          try {
            progress = typeof data === 'string' ? JSON.parse(data).status : data.status;
          } catch (e) {
            console.error('Failed to parse progress data:', e);
            return;
          }
  
          const progressBar = $('.progress-bar');
          console.log('Progress:', progress);
          progressBar.css('width', `${progress}%`);
          progressBar.attr('aria-valuenow', progress);
          progressBar.text(`${progress}%`);
  
          if (progress < 100) {
            setTimeout(updateProgress, 1000);  // Keep updating until progress is 100%
          } else {
            console.log('Progress complete!');
          }
        },
        error: function (xhr, status, error) {
          console.error('Error fetching progress:', error);
        }
      });
    }
  
    updateProgress();
  
    $('form').on('submit', function (e) {
      e.preventDefault();
      console.log('Form submitted');
  
      // Reset progress bar
      const progressBar = $('.progress-bar');
      progressBar.css('width', '0%');
      progressBar.attr('aria-valuenow', 0);
      progressBar.text('0%');
  
      const formData = $(this).serialize();
      console.log('Form data:', formData); 
  
      // Submit form via AJAX
      $.ajax({
        url: '/submit',
        method: 'POST',
        data: formData,
        success: function () {
          console.log('Form submitted successfully, starting progress update');
          updateProgress(); 
        },
        error: function (xhr, status, error) {
          console.error('Error submitting form:', error);
          alert('An error occurred. Please try again.');
        }
      });
    });
  });
  