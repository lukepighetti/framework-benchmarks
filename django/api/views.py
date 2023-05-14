from django.http import HttpResponse


def health_check(request):
    return HttpResponse("OK", content_type="text/plain", status=200)
